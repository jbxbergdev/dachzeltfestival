import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dachzeltfestival/model/configuration/map_config.dart';
import 'package:dachzeltfestival/util/utils.dart';
import 'package:dachzeltfestival/view/map/icon_map.dart';
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
  RubberAnimationController _bottomSheetController;
  ScrollController _scrollController = ScrollController();
  BehaviorSubject<geojson.Feature> _featureSubject;
  Observable<_GoogleMapData> _mapDataStream;
  CameraPosition _cameraPosition;
  CompositeSubscription _compositeSubscription = CompositeSubscription();

  static const double _headerHeightPx = 80;

  _EventMapState(this._eventMapViewModel, this._featureConverter);

  @override
  void initState() {
    super.initState();
    _featureSubject = BehaviorSubject.seeded(null);
    _bottomSheetController = RubberAnimationController(
        vsync: this,
        upperBoundValue: AnimationControllerValue(pixel: _headerHeightPx),
//        halfBoundValue: AnimationControllerValue(percentage: 0.5),
        lowerBoundValue: AnimationControllerValue(percentage: 0.0),
        duration: Duration(milliseconds: 200),
        initialValue: 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RubberBottomSheet(
      scrollController: _scrollController,
      lowerLayer: Stack(
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
          )
        ],
      ),
      header: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.0),
        child: SizedBox.expand(
          child: StreamBuilder<geojson.Feature>(
              initialData: geojson.Feature(),
              stream: _featureSubject.stream,
              builder: (buildContext, snapshot) {
                return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16)
                      ),
                    ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: snapshot?.data is geojson.Point ? Colors.white : hexToColor(snapshot?.data?.properties?.fill).withOpacity(0.2),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16)
                      ),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                        child: Row(
                          children: <Widget>[
                            snapshot?.data is geojson.Point && snapshot.data.properties != null ?
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0, bottom: 4.0),
                              child: Icon(
                                iconDataMap[snapshot.data.properties.pointCategory].icon,
                                color: iconDataMap[snapshot.data.properties.pointCategory].color,
                                size: 40.0,),
                            )
                            : Container(),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: AutoSizeText(
                                snapshot?.data?.properties?.name ?? "",
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
          ),
        ),
      ),
      headerHeight: _headerHeightPx,
      upperLayer: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Container(
          child: StreamBuilder<geojson.Feature>(
            stream: _featureSubject.stream,
            builder: (buildContext, snapshot) {
              return Container(
                constraints: BoxConstraints.expand(),
                color: Colors.white,
                child: snapshot?.data?.properties?.description != null ?
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      snapshot.data.properties?.description,
                      style: TextStyle(
                        color: Colors.black,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  )
                  : Container(),
              );
            },
          ),
        ),
      ),
      animationController: _bottomSheetController,
    );
  }

  void _onPolygonTapped(geojson.Feature feature) {
    _featureSubject.add(feature);
    _bottomSheetController.expand();
  }

  void _onMarkerTapped(geojson.Feature feature) {
    _featureSubject.add(feature);
    _bottomSheetController.expand();
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

  BehaviorSubject<_GoogleMapData> _mapData() {
    if (_mapDataStream == null) {
      _mapDataStream = BehaviorSubject.seeded(null);

      Observable<_GoogleMapData> mapDataObservable = _eventMapViewModel.mapData()
          .flatMap((mapData) => _featureConverter.parseFeatureCollection(mapData.mapFeatures, _onPolygonTapped, _onMarkerTapped).asStream()
          .map((mapsFeatures) => _GoogleMapData(mapsFeatures.polygons, mapsFeatures.markers, mapData.locationPermissionGranted, mapData.mapConfig)));

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
  final bool locationPermissionGranted;
  final MapConfig mapConfig;

  _GoogleMapData(this.polygons, this.markers, this.locationPermissionGranted, this.mapConfig);
}