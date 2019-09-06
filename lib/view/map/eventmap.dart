import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tuple/tuple.dart';
import 'eventmap_viewmodel.dart';
import 'geojson_gmaps_converter.dart';
import 'package:inject/inject.dart';
import 'package:dachzeltfestival/model/geojson/feature.dart' as geojson;
import 'package:rubber/rubber.dart';
import 'package:rxdart/rxdart.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';

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
  CameraPosition _cameraPosition = CameraPosition(
    target: LatLng(49.137756, 10.876035),
    zoom: 16.0,
  );
  final EventMapViewModel _eventMapViewModel;
  final FeatureConverter _featureConverter;
  final PermissionHandler _permissionHandler = PermissionHandler();
  RubberAnimationController _controller;
  ScrollController _scrollController = ScrollController();
  BehaviorSubject<geojson.Properties> _propertiesSubject;
  Stream<Tuple2<Set<Polygon>, bool>> _polygonsAndLocationPermissionStream;

  _EventMapState(this._eventMapViewModel, this._featureConverter);

  @override
  void initState() {
    super.initState();
    _propertiesSubject = BehaviorSubject.seeded(null);
    _controller = RubberAnimationController(
        vsync: this,
        halfBoundValue: AnimationControllerValue(percentage: 0.5),
        lowerBoundValue: AnimationControllerValue(percentage: 0.0),
        duration: Duration(milliseconds: 200),
        initialValue: 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {

    return RubberBottomSheet(
      scrollController: _scrollController,
      lowerLayer: StreamBuilder<Tuple2<Set<Polygon>, bool>>(
          stream: _polygonsAndLocationPermission(),
          builder: (buildContext, snapshot) {
            bool myLocationEnabled = snapshot.data?.item2 ?? false;
            return GoogleMap(
              initialCameraPosition: _cameraPosition,
              myLocationEnabled: myLocationEnabled,
              polygons: snapshot.data?.item1 ?? Set(),
              onMapCreated: _onMapCreated,
              onCameraMove: _onCameraMove,
              onTap: _onTap,
            );
          }),
      header: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16)
              )
          ),
          child: StreamBuilder<geojson.Properties>(
            initialData: geojson.Properties(),
            stream: _propertiesSubject.stream,
            builder: (buildContext, snapshot) {
              return Container(child: Text(snapshot.data?.name ?? ""));
            },
          ),
        ),
      ),
      headerHeight: 60,
      upperLayer: StreamBuilder<geojson.Properties>(
        stream: _propertiesSubject.stream,
        builder: (buildContext, snapshot) {
//          String url = Uri.dataFromString(snapshot.data?.description ?? "<p>", mimeType: 'text/
        String url = Uri.dataFromString("<html><body><p>Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod "
            "tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. "
            "Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing "
            "elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo "
            "duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.</body></html>", mimeType: 'text/html').toString();
          return WebView(
            initialUrl: url,
          );
        },
      ),
      animationController: _controller,
    );
  }

  void _onPolygonTapped(geojson.Properties properties) {
    _propertiesSubject.add(properties);
    _controller.animateTo(to: 0.5);
  }

  void _onMapCreated(GoogleMapController controller) {
    _googleMapController = controller;
  }

  void _onCameraMove(CameraPosition cameraPosition) {
    _cameraPosition = cameraPosition;
  }

  void _onTap(LatLng tapCoords) {
    _controller.collapse();
  }

  Stream<Tuple2<Set<Polygon>, bool>> _polygonsAndLocationPermission() {
    if (_polygonsAndLocationPermissionStream == null) {
      Stream<Set<Polygon>> polygonStream = _eventMapViewModel
          .observeMapFeatures()
          .asyncMap((featureCollection) =>
          _featureConverter.parseFeatureCollection(
              featureCollection, _onPolygonTapped));
      _polygonsAndLocationPermissionStream = Observable(_checkLocationPermission().asStream())
          .flatMap((permissionGranted) =>
          polygonStream.map((polygons) => Tuple2(polygons, permissionGranted)));
    }
    return _polygonsAndLocationPermissionStream;
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