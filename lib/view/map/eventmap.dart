import 'dart:collection';
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
  BehaviorSubject<geojson.Feature> _featureSubject;
  Observable<_GoogleMapData> _mapDataStream;
  CameraPosition _cameraPosition;
  CompositeSubscription _compositeSubscription = CompositeSubscription();
  BehaviorSubject<double> _widgetHeightSubject = BehaviorSubject.seeded(null);

  static const double _headerHeightPx = 80.0;

  _EventMapState(this._eventMapViewModel, this._featureConverter);

  @override
  void initState() {
    super.initState();
    _featureSubject = BehaviorSubject.seeded(null);
  }

  @override
  Widget build(BuildContext context) {

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
          bottom: 10,
          right: 10,
          child: FloatingActionButton(
            onPressed: _startNavigationApp,
            child: Icon(
              Icons.navigation,
              color: Theme.of(context).primaryColor,
            ),
            backgroundColor: Colors.grey[100],
          ),
        ),
        StreamBuilder<Tuple2<geojson.Feature, double>>(
          stream: Observable.combineLatest2(_featureSubject, _widgetHeightSubject, (feature, height) => Tuple2(feature, height)),
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
    _featureSubject.add(feature);
    _eventMapViewModel.selectedFeatureId.add(feature.properties.placeId);
  }

  void _onMapCreated(GoogleMapController controller) {
    _googleMapController = controller;
    _googleMapController.setMapStyle(mapStyle);
    _compositeSubscription.add(_eventMapViewModel.zoomToFeatureId.flatMap((featureId) => _mapData().map((mapData) {
      return Tuple3(featureId, mapData.pointCoordinates, mapData.polygonBoundingBoxes);
    })).listen((tuple3) {
      final bbox = tuple3.item3[tuple3.item1];
      if (bbox != null) {
        _googleMapController.animateCamera(CameraUpdate.newLatLngBounds(bbox, 16.0));
      }
    }));
  }

  void _onCameraMove(CameraPosition cameraPosition) {
    _cameraPosition = cameraPosition;
  }

  void _onTap(LatLng tapCoords) {
    _featureSubject.add(null);
    _eventMapViewModel.selectedFeatureId.add(null);
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

  Observable<_GoogleMapData> _mapData() {
    if (_mapDataStream == null) {
      _mapDataStream = BehaviorSubject.seeded(null);

      Observable<_GoogleMapData> mapDataObservable = _eventMapViewModel.mapData()
          .flatMap((mapData) => _featureConverter.parseFeatureCollection(mapData.mapFeatures, mapData.selectedPlaceId, _onMapItemTapped, _onMapItemTapped).asStream()
          .map((mapsFeatures) {
            return _GoogleMapData(mapsFeatures.polygons, mapsFeatures.markers, mapsFeatures.polygonBoundingBoxes, mapsFeatures.pointCoordinates, mapData.locationPermissionGranted, mapData.mapConfig);
          }));

      _compositeSubscription.add(mapDataObservable.listen((mapData) => (_mapDataStream as BehaviorSubject<_GoogleMapData>).value = mapData));
    }
    return _mapDataStream;
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
  final Map<String, LatLngBounds> polygonBoundingBoxes;
  final Map<String, LatLng> pointCoordinates;
  final bool locationPermissionGranted;
  final MapConfig mapConfig;

  _GoogleMapData(this.polygons, this.markers, this.polygonBoundingBoxes, this.pointCoordinates, this.locationPermissionGranted, this.mapConfig);
}