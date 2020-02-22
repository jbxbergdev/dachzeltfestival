import 'dart:io';
import 'dart:math';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dachzeltfestival/model/configuration/map_config.dart';
import 'package:dachzeltfestival/util/utils.dart';
import 'package:dachzeltfestival/view/map/icon_map.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';
import 'eventmap_viewmodel.dart';
import 'geojson_gmaps_converter.dart';
import 'package:inject/inject.dart';
import 'package:dachzeltfestival/model/geojson/feature.dart' as geojson;
import 'package:rxdart/rxdart.dart';
import 'map_settings.dart';
import 'package:dachzeltfestival/model/geojson/place_category.dart';

typedef Provider<T> = T Function();

@provide
class EventMapBuilder {
  final Provider<EventMapViewModel> _vmProvider;
  final FeatureConverter _featureConverter;
  EventMapBuilder(this._vmProvider, this._featureConverter);

  EventMap build(Key key) => EventMap(key, _vmProvider, _featureConverter);
}

class EventMap extends StatefulWidget {

  final Provider<EventMapViewModel> _vmProvider;
  final FeatureConverter _featureConverter;

  EventMap(Key key, this._vmProvider, this._featureConverter): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EventMapState(_vmProvider(), _featureConverter);
  }
}

class _EventMapState extends State<EventMap> with SingleTickerProviderStateMixin {

  GoogleMapController _googleMapController;
  final EventMapViewModel _eventMapViewModel;
  final FeatureConverter _featureConverter;
  Stream<_GoogleMapData> _mapDataStream;
  Stream<GoogleMapsGeometries> _geometriesStream;
  CameraPosition _cameraPosition;
  CompositeSubscription _compositeSubscription = CompositeSubscription();
  BehaviorSubject<double> _widgetHeightSubject = BehaviorSubject.seeded(null);
  BehaviorSubject<geojson.Feature> _selectedPlaceSubject = BehaviorSubject.seeded(null);
  BehaviorSubject<bool> _mapInitialized = BehaviorSubject.seeded(false);
  BehaviorSubject<bool> _layoutDone = BehaviorSubject.seeded(false);
  BehaviorSubject<int> _detailLevel = BehaviorSubject.seeded(null);
  CompositeSubscription _zoomCompositeSubscription = CompositeSubscription();

  static const double _headerHeightPx = 80.0;
  static const double _teaserHeightPx = 24.0;
  static const double _imageHeightPx = 120.0;
  static const double _sheetLinkIconHeight = 24.0;
  static const double _sheetItemsBottomPadding = 8.0;
  static const double _expandedSheetRelativeHeight = 0.8;
  static const double _detailLevelZoomThreshold = 1000; // TODO Set to actually possible zoom level as soon as https://github.com/jbxbergdev/dachzeltfestival/issues/51 can be implemented.

  _EventMapState(this._eventMapViewModel, this._featureConverter);

  @override
  void initState() {
    super.initState();

    _layoutDone.add(false);
    _mapInitialized.add(false);

    _listenToZoomRequests();
  }

  @override
  Widget build(BuildContext context) {
    _layoutDone.add(false);
    _mapInitialized.add(_googleMapController != null);
    WidgetsBinding.instance.addPostFrameCallback((_) => _layoutDone.add(true));

    // We need to know the widget height to calculate the bottom sheet initial height.
    // But we can only know this after the widget tree has been rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _widgetHeightSubject.add(context.size.height);
    });
    _widgetHeightSubject.add(null);

    return Stack(
      children: <Widget>[
        StreamBuilder<_GoogleMapData>(
            stream: _mapData(),
            builder: (buildContext, snapshot) {
              if (snapshot.data?.mapConfig != null && snapshot.data.locationPermissionGranted != null) { // TODO null initial value is a workaround for https://github.com/jbxbergdev/dachzeltfestival/issues/37
                _GoogleMapData mapData = snapshot.data;
                geojson.Coordinates initialMapCenter = mapData.mapConfig.initalMapCenter;
                if (initialMapCenter != null && _cameraPosition == null) {
                  _cameraPosition = CameraPosition(target: LatLng(
                      initialMapCenter.lat, initialMapCenter.lng),
                      zoom: mapData.mapConfig.initialZoomLevel);
                }
                return GoogleMap(
                  initialCameraPosition: _cameraPosition,
                  myLocationButtonEnabled: false,
                  myLocationEnabled: mapData.locationPermissionGranted,
                  tiltGesturesEnabled: false,
                  rotateGesturesEnabled: false,
                  mapType: MapType.hybrid,
                  polygons: mapData?.polygons ?? Set(),
                  markers: mapData?.markers ?? Set(),
                  onMapCreated: _onMapCreated,
                  onCameraMove: _onCameraMove,
                  onTap: _onTap,
                );
              }
              return Container();
            }),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _startNavigationApp,
            child: Icon(
              Icons.directions_car,
              color: Theme.of(context).primaryColor,
            ),
            backgroundColor: Colors.grey[100],
          ),
        ),
        SizedBox.expand(
          child: StreamBuilder<Tuple2<geojson.Feature, double>>(
            stream: Rx.combineLatest2(_selectedPlaceSubject, _widgetHeightSubject, (feature, height) => Tuple2(feature, height)),
            builder: (buildContext, snapshot) {
              if (!snapshot.hasData || snapshot.data.item1 == null || snapshot.data.item2 == null) {
                return Container(key: UniqueKey());
              }
              final listKey = PageStorageKey(DateTime.now());
              return SlidingUpPanel(
                margin: EdgeInsets.symmetric(horizontal: 8.0),
                borderRadius: BorderRadius.circular(16.0),
                maxHeight: _maxSheetHeight(snapshot.data.item1, snapshot.data.item2),
                minHeight: _initialSheetHeight(snapshot.data.item1, snapshot.data.item2),
                panelBuilder: (scrollController) {
                  return ClipRRect(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0)),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white),
                      child: ListView(
                        key: listKey,
                        controller: scrollController,
                        children: <Widget>[
                        StickyHeader(
                          header: _header(snapshot.data.item1),
                          content: _description(snapshot.data.item1),
                        ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  double _initialSheetHeight(geojson.Feature feature, double totalWidgetHeight) {
    final properties = feature.properties;
    if (properties.description != null || properties.url != null || properties.imageUrl != null) {
      return _headerHeightPx + _teaserHeightPx;
    }
    return _headerHeightPx;
  }

  double _maxSheetHeight(geojson.Feature feature, double totalWidgetHeight) {
    final properties = feature.properties;
    if (properties.description != null) {
      return _expandedSheetRelativeHeight * totalWidgetHeight;
    }
    double height = _headerHeightPx;
    if (properties.url != null) {
      height += (_sheetLinkIconHeight + _sheetItemsBottomPadding * 2);
    }
    if (properties.imageUrl != null) {
      height += (_imageHeightPx + _sheetItemsBottomPadding);
    }
    return height;
  }

  Widget _header(geojson.Feature feature) {
    return Container(
      color: Colors.white,
      child: Container(
        height: _headerHeightPx,
        decoration: BoxDecoration(
          color: (feature.properties.fill != null ? hexToColor(feature.properties.fill) : Theme.of(context).colorScheme.primary).withOpacity(0.2),
        ),
        child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ),
            child: Row(
              children: <Widget>[
                _headerIcon(feature),
                Container(
                  child: Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AutoSizeText(
                        feature.properties?.name ?? "",
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w300
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                )
              ],
            )
        ),
      ),
    );
  }

  Widget _headerIcon(geojson.Feature feature) {

    final size = 40.0;
    final padding = EdgeInsets.only(right: 8.0, bottom: 4.0);

    if (feature.properties.logoUrl != null) {
      return Padding(
        padding: padding,
        child: CachedNetworkImage(
          imageUrl: feature.properties.logoUrl,
          height: size,
          width: size,
          fit: BoxFit.contain,
        ),
      );
    }

    if (feature is geojson.Point) {
      return Padding(
        padding: padding,
        child: Icon(
          iconDataMap[feature.properties.mappedCategory].icon,
          color: iconDataMap[feature.properties.mappedCategory].color,
          size: size,
        ),
      );
    }

    return Container();
  }

  Widget _description(geojson.Feature feature) {
    final properties = feature.properties;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        properties.imageUrl != null
            ? Padding(
              padding: const EdgeInsets.only(bottom: _sheetItemsBottomPadding),
              child: CachedNetworkImage(
                  imageUrl: properties.imageUrl,
                  fit: BoxFit.cover,
                  height: _imageHeightPx,
                  width: double.infinity,
                ),
            )
            : Container(height: 8.0,),
        properties.url != null
            ? Material(
              color: Colors.transparent,
              child: InkWell(
                  onTap: () => launch(properties.url),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: _sheetItemsBottomPadding),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(
                            Icons.public,
                            size: _sheetLinkIconHeight,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Container(
                          child: Expanded(
                            child: TextOneLine(
                              properties.url,
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
              ),
            )
            : Container(),
        properties.description != null ? Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
            child: Text(
              properties.description,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ) : Container(),
      ],
    );
  }

  void _onMapItemTapped(geojson.Feature feature) {
    _selectedPlaceSubject.first.then((selectedFeature) => _selectedPlaceSubject.add(selectedFeature == null ? feature : null));
  }

  void _onMapCreated(GoogleMapController controller) {
    _googleMapController = controller;
    _googleMapController.setMapStyle(mapStyle);
    _mapInitialized.add(true);
  }

  void _onCameraMove(CameraPosition cameraPosition) {
    _cameraPosition = cameraPosition;
    _updateDetailLevel(_cameraPosition.zoom);
  }

  void _onTap(LatLng tapCoords) {
    _selectedPlaceSubject.add(null);
  }

  void _startNavigationApp() async {
    MapConfig mapConfig = (await _mapData().first).mapConfig;
    geojson.Coordinates navDestination = mapConfig?.navDestination;
    if (navDestination != null) {
      if (Platform.isAndroid) {
        launch("https://www.google.com/maps/dir/?api=1&destination=${navDestination.lat},${navDestination.lng}");
      } else if (Platform.isIOS) {
        launch("http://maps.apple.com/?daddr=${navDestination.lat},${navDestination.lng}");
      }
    }
  }

  Stream<_GoogleMapData> _mapData() {

    if (_mapDataStream == null) {

      // Minimize expensive map data parsing by caching in a BehaviorSubject
      _mapDataStream = BehaviorSubject.seeded(null);

      // Merge map geometries, selectedPlaceId, zoomId and location permission state
      Stream<Tuple4<GoogleMapsGeometries, String, MapConfig, bool>> dataValuesStream = Rx.combineLatest4(
          _mapGeometries(),
          _selectedPlaceSubject.map((feature) => feature?.properties?.placeId),
          _eventMapViewModel.mapConfig(),
          _eventMapViewModel.locationPermissionGranted(),
              (mapGeometries, selectedPlaceId, mapConfig, locationPermissionGranted) => Tuple4(mapGeometries, selectedPlaceId, mapConfig, locationPermissionGranted));

      // Parse Features to GoogleMaps objects, combine all the results to _GoogleMapData object
      Stream<_GoogleMapData> mapDataObservable = dataValuesStream
          .map((values) {
              return _GoogleMapData(values.item1.polygons(values.item2),
                  values.item1.markers(values.item2),
                  values.item4,
                  values.item3);
          });

      _compositeSubscription.add(mapDataObservable.listen((mapData) => (_mapDataStream as BehaviorSubject<_GoogleMapData>).value = mapData));
    }
    return _mapDataStream;
  }

  Stream<GoogleMapsGeometries> _mapGeometries() {
    if (_geometriesStream == null) {
      // cache the geometries in a Behaviorsubject as the creation may be expensive
      _geometriesStream = BehaviorSubject();
      final featuresDetailLevelStream = Rx.combineLatest2(_eventMapViewModel.features(), _detailLevel.distinct(), (features, detailLevel) => Tuple2(features, detailLevel ?? 0));
      final subscription = featuresDetailLevelStream
          .flatMap((featuresDeatilLevel) => _featureConverter.parseFeatureCollection(featuresDeatilLevel.item1, featuresDeatilLevel.item2, _onMapItemTapped, _onMapItemTapped).asStream())
          .listen((googleMapsGeometries) => (_geometriesStream as BehaviorSubject<GoogleMapsGeometries>).add(googleMapsGeometries));
      _compositeSubscription.add(subscription);
    }
    return _geometriesStream;
  }

  void _listenToZoomRequests() {
    // before zooming is possible, layout must be complete and a GoogleMapController must be available. Listen to these states.
    final mapReadySub = Rx.combineLatest2(_layoutDone, _mapInitialized, (layoutDone, mapInitialized) => layoutDone && mapInitialized)
        .listen((mapReady) {
      if (mapReady) {
        final zoomSub = _eventMapViewModel.zoomToFeatureId.where((zoomId) => zoomId != null)
            .flatMap((zoomId) => _eventMapViewModel.features().first.asStream().map((features) => features.features.firstWhere((feature) => feature.properties.placeId == zoomId)))
            .listen((feature) {
          if (feature is geojson.Polygon) {
            _googleMapController.animateCamera(CameraUpdate.newLatLngBounds(feature.boundingBox(), 64.0));
          } else if (feature is geojson.Point) {
            _googleMapController.animateCamera(CameraUpdate.newLatLngZoom(feature.toLatLng(), 18.0));
          }
          _selectedPlaceSubject.add(feature);
          _eventMapViewModel.zoomHandled();
        });
        _zoomCompositeSubscription.add(zoomSub);
      } else {
        _zoomCompositeSubscription.clear();
      }
    });
    _compositeSubscription.add(mapReadySub);
  }

  void _updateDetailLevel(double zoom) {
    int detailLevel;
    if (zoom < _detailLevelZoomThreshold) {
      detailLevel = 0;
    } else {
      detailLevel = 1;
    }
    _detailLevel.add(detailLevel);
  }

  @override
  void dispose() {
    _compositeSubscription.clear();
    super.dispose();
  }
}

class _GoogleMapData {

  final Set<Polygon> polygons;
  final Set<Marker> markers;
  final bool locationPermissionGranted;
  final MapConfig mapConfig;

  _GoogleMapData(this.polygons, this.markers, this.locationPermissionGranted, this.mapConfig);
}


extension on geojson.Polygon {

  LatLngBounds boundingBox() {

    double north = -90.0;
    double south = 90.0;
    double west = 180.0;
    double east = -180.0;

    this.coordinates.forEach((coordinates) {
      coordinates.forEach( (latLng) {
        north = max(north, latLng.lat);
        south = min(south, latLng.lat);
        west = min(west, latLng.lng);
        east = max(east, latLng.lng);
      });
    });

    // in case there is an event somewhere in the Pacific
    if (east - west > 180.0) {
      final tempWest = west;
      west = east;
      east = tempWest;
    }

    return LatLngBounds(northeast: LatLng(north, east), southwest: LatLng(south, west));
  }
}

extension on geojson.Point {
  LatLng toLatLng() => LatLng(this.coordinates.lat, this.coordinates.lng);
}