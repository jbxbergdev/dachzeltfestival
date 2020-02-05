import 'dart:io';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dachzeltfestival/model/configuration/map_config.dart';
import 'package:dachzeltfestival/util/utils.dart';
import 'package:dachzeltfestival/view/map/icon_map.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';
import 'eventmap_viewmodel.dart';
import 'geojson_gmaps_converter.dart';
import 'package:inject/inject.dart';
import 'package:dachzeltfestival/model/geojson/feature.dart' as geojson;
import 'package:rxdart/rxdart.dart';
import 'map_settings.dart';
import 'package:dachzeltfestival/model/geojson/point_category.dart';

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
  CompositeSubscription _zoomCompositeSubscription = CompositeSubscription();

  static const double _headerHeightPx = 80.0;

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
        StreamBuilder<Tuple2<geojson.Feature, double>>(
          stream: Rx.combineLatest2(_selectedPlaceSubject, _widgetHeightSubject, (feature, height) => Tuple2(feature, height)),
          builder: (buildContext, snapshot) {
            if (!snapshot.hasData || snapshot.data.item1 == null || snapshot.data.item2 == null) {
              return Container();
            }
            return DraggableScrollableSheet(
                minChildSize: 0.0,
                initialChildSize: _headerHeightPx / snapshot.data.item2,
                maxChildSize: 0.7,
                builder: (buildContext, scrollController) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: _header(snapshot.data.item1),
                  );
                },
            );
          },
        ),
      ],
    );
  }

  Widget _header(geojson.Feature feature) {
    return Container(
      height: _headerHeightPx,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: feature is geojson.Point
              ? Colors.white
              : hexToColor(feature.properties?.fill)
              .withOpacity(0.2),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ),
            child: Row(
              children: <Widget>[
                feature is geojson.Point &&
                    feature.properties != null ?
                Padding(
                  padding: const EdgeInsets.only(
                      right: 8.0, bottom: 4.0),
                  child: Icon(
                    iconDataMap[feature.properties.pointCategory].icon,
                    color: iconDataMap[feature.properties.pointCategory].color,
                    size: 40.0,
                  ),
                )
                    : Container(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: AutoSizeText(
                    feature.properties?.name ?? "",
                    style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w300
                    ),
                    minFontSize: 16,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            )
        ),
      ),
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
      Stream<Tuple4<GoogleMapsGeometries, String, MapConfig, bool>> mapGeometriesSelectedPlaceMapConfigLocationPermission = Rx.combineLatest4(
          _mapGeometries(),
          _selectedPlaceSubject.map((feature) => feature?.properties?.placeId),
          _eventMapViewModel.mapConfig(),
          _eventMapViewModel.locationPermissionGranted(),
              (mapGeometries, selectedPlaceId, mapConfig, locationPermissionGranted) => Tuple4(mapGeometries, selectedPlaceId, mapConfig, locationPermissionGranted));

      // Parse Features to GoogleMaps objects, combine all the results to _GoogleMapData object
      Stream<_GoogleMapData> mapDataObservable = mapGeometriesSelectedPlaceMapConfigLocationPermission
          .map((geometriesSelectedIdConfigPermission) {
              return _GoogleMapData(geometriesSelectedIdConfigPermission.item1.polygons(geometriesSelectedIdConfigPermission.item2),
                  geometriesSelectedIdConfigPermission.item1.markers(geometriesSelectedIdConfigPermission.item2),
                  geometriesSelectedIdConfigPermission.item4,
                  geometriesSelectedIdConfigPermission.item3);
          });

      _compositeSubscription.add(mapDataObservable.listen((mapData) => (_mapDataStream as BehaviorSubject<_GoogleMapData>).value = mapData));
    }
    return _mapDataStream;
  }

  Stream<GoogleMapsGeometries> _mapGeometries() {
    if (_geometriesStream == null) {
      // cache the geometries in a Behaviorsubject as the creation may be expensive
      _geometriesStream = BehaviorSubject();
      final subscription = _eventMapViewModel.features()
          .flatMap((features) => _featureConverter.parseFeatureCollection(features, _onMapItemTapped, _onMapItemTapped).asStream())
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