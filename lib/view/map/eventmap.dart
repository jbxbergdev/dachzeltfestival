import 'dart:io';

import 'package:dachzeltfestival/model/configuration/map_config.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
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
  RubberAnimationController _bottomSheetController;
  ScrollController _scrollController = ScrollController();
  BehaviorSubject<geojson.Properties> _propertiesSubject;
  Observable<GoogleMapData> _mapDataStream;
  CameraPosition _cameraPosition;
  CompositeSubscription _compositeSubscription = CompositeSubscription();

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
          StreamBuilder<GoogleMapData>(
              stream: _mapData(),
              builder: (buildContext, snapshot) {
                if (snapshot.data?.mapConfig != null && snapshot.data.locationPermissionGranted != null) { // TODO null initial value is a workaround for https://github.com/jbxbergdev/dachzeltfestival/issues/37
                  GoogleMapData mapData = snapshot.data;
                  geojson.Coordinates initialMapCenter = mapData.mapConfig.initalMapCenter;
                  if (initialMapCenter != null && _cameraPosition == null) {
                    _cameraPosition = CameraPosition(target: LatLng(
                        initialMapCenter.lat, initialMapCenter.lng),
                        zoom: mapData.mapConfig.initialZoomLevel);
                  }
                  print('##### rebuild map');
                  return GoogleMap(
                    initialCameraPosition: _cameraPosition,
                    myLocationButtonEnabled: false,
                    myLocationEnabled: mapData.locationPermissionGranted,
                    mapType: MapType.hybrid,
                    polygons: mapData?.polygons ?? Set(),
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
    print('##### onMaoCreated');
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

  BehaviorSubject<GoogleMapData> _mapData() {
    if (_mapDataStream == null) {
      _mapDataStream = BehaviorSubject.seeded(null);

    Observable<GoogleMapData> mapDataObservable = _eventMapViewModel.mapData()
        .flatMap((mapData) => _featureConverter.parseFeatureCollection(mapData.mapFeatures, _onPolygonTapped).asStream().map((googlePolygons) => GoogleMapData(googlePolygons, mapData.locationPermissionGranted, mapData.mapConfig)));

    _compositeSubscription.add(mapDataObservable.listen((mapData) => (_mapDataStream as BehaviorSubject<GoogleMapData>).value = mapData));
    }
    return _mapDataStream;
  }

  @override
  void deactivate() {
    _compositeSubscription.clear();
    super.deactivate();
  }
}

class GoogleMapData {
  final Set<Polygon> polygons;
  final bool locationPermissionGranted;
  final MapConfig mapConfig;

  GoogleMapData(this.polygons, this.locationPermissionGranted, this.mapConfig);
}