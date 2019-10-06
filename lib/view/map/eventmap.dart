import 'dart:io';

import 'package:dachzeltfestival/model/configuration/map_config.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';
import 'eventmap_viewmodel.dart';
import 'geojson_gmaps_converter.dart';
import 'package:inject/inject.dart';
import 'package:dachzeltfestival/model/geojson/feature.dart' as geojson;
import 'package:rubber/rubber.dart';
import 'package:rxdart/rxdart.dart';
import 'map_settings.dart';

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
  final PermissionHandler _permissionHandler = PermissionHandler();
  RubberAnimationController _bottomSheetController;
  ScrollController _scrollController = ScrollController();
  BehaviorSubject<geojson.Properties> _propertiesSubject;
  Observable<MapData> _mapDataStream;
  CameraPosition _cameraPosition;

  _EventMapState(this._eventMapViewModel, this._featureConverter);

  @override
  void initState() {
    super.initState();
    _propertiesSubject = BehaviorSubject.seeded(null);
    _bottomSheetController = RubberAnimationController(
        vsync: this,
        halfBoundValue: AnimationControllerValue(percentage: 0.5),
        lowerBoundValue: AnimationControllerValue(percentage: 0.0),
        duration: Duration(milliseconds: 200),
        initialValue: 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    _eventMapViewModel.localeSubject.value = Localizations.localeOf(context);
    return RubberBottomSheet(
      scrollController: _scrollController,
      lowerLayer: Stack(
        children: <Widget>[
          StreamBuilder<MapData>(
              stream: _mapData(),
              builder: (buildContext, snapshot) {
                if (snapshot.hasData) {
                  MapData mapData = snapshot.data;
                  geojson.Coordinates initialMapCenter = mapData?.mapConfig?.initalMapCenter;
                  if (initialMapCenter != null && _cameraPosition == null) {
                    _cameraPosition = CameraPosition(target: LatLng(
                        initialMapCenter.lat, initialMapCenter.lng),
                        zoom: mapData.mapConfig.initialZoomLevel);
                  }
                  return GoogleMap(
                    initialCameraPosition: _cameraPosition,
                    myLocationButtonEnabled: false,
                    myLocationEnabled: mapData?.locationPermissionGranted ?? false,
                    polygons: mapData?.polygons ?? Set(),
                    onMapCreated: _onMapCreated,
                    onCameraMove: _onCameraMove,
                    onTap: _onTap,
                  );
                }
                return Text("");
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
          )
        ],
      ),
      header: SizedBox.expand(

        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16)
              )
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder<geojson.Properties>(
              initialData: geojson.Properties(),
              stream: _propertiesSubject.stream,
              builder: (buildContext, snapshot) {
                return Container(
                  child: Text(
                    snapshot.data?.name ?? "",
                    style: TextStyle(fontSize: 16),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      headerHeight: 60,
      upperLayer: Container(
        child: StreamBuilder<geojson.Properties>(
          stream: _propertiesSubject.stream,
          builder: (buildContext, snapshot) {
            return Container(
              constraints: BoxConstraints.expand(),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Hier werden mal Informationen zum angeklickten Ort stehen.",
                  style: TextStyle(
                    color: Colors.black,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      animationController: _bottomSheetController,
    );
  }

  void _onPolygonTapped(geojson.Properties properties) {
    _propertiesSubject.add(properties);
    _bottomSheetController.animateTo(to: 0.3);
  }

  void _onMapCreated(GoogleMapController controller) {
    _googleMapController = controller;
    _googleMapController.setMapStyle(mapStyle);
  }

  void _onCameraMove(CameraPosition cameraPosition) {
    _cameraPosition = cameraPosition;
  }

  void _onTap(LatLng tapCoords) {
    _bottomSheetController.collapse();
  }

  void _startNavigationApp() async {
    MapConfig mapConfig = await (_eventMapViewModel.mapConfig as BehaviorSubject<MapConfig>).first;
    geojson.Coordinates navDestination = mapConfig?.navDestination;
    if (navDestination != null) {
      if (Platform.isAndroid) {
        launch("https://www.google.com/maps/dir/?api=1&destination=${navDestination.lat},${navDestination.lng}");
      } else if (Platform.isIOS) {
        launch("http://maps.apple.com/?daddr=${navDestination.lat},${navDestination.lng}");
      }
    }
  }

  Observable<MapData> _mapData() {
    if (_mapDataStream == null) {
      Observable<Set<Polygon>> polygonStream = _eventMapViewModel
          .mapFeatures
          .asyncMap((featureCollection) => _featureConverter.parseFeatureCollection(featureCollection, _onPolygonTapped));
      Observable<Tuple2<Set<Polygon>, MapConfig>> polygonAndMapConfigStream = Observable.combineLatest2(
          polygonStream, _eventMapViewModel.mapConfig, (polygons, mapConfig) => Tuple2(polygons, mapConfig));

      _mapDataStream = Observable(_checkLocationPermission().asStream())
          .flatMap((permissionGranted) => polygonAndMapConfigStream.map((polygonsAndMapConfig) => MapData(polygonsAndMapConfig.item1, permissionGranted, polygonsAndMapConfig.item2)));
    }
    return _mapDataStream;
  }

  Future<bool> _checkLocationPermission() {
    return _permissionHandler.checkPermissionStatus(PermissionGroup.locationWhenInUse)
        .then((permissionStatus) {
      switch (permissionStatus) {
        case PermissionStatus.granted:
          return Future.value(true);
        default:
          return _permissionHandler.requestPermissions([PermissionGroup.locationWhenInUse])
              .then((statusMap) => Future.value(statusMap[PermissionGroup.locationWhenInUse] == PermissionStatus.granted
              || statusMap[PermissionGroup.location] == PermissionStatus.restricted));
      }
    });
  }
}

class MapData {
  final Set<Polygon> polygons;
  final bool locationPermissionGranted;
  final MapConfig mapConfig;

  MapData(this.polygons, this.locationPermissionGranted, this.mapConfig);
}