import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'eventmap_viewmodel.dart';
import 'geojson_gmaps_converter.dart';
import 'package:inject/inject.dart';
import 'map_feature.dart';

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

class _EventMapState extends State<EventMap> {

  GoogleMapController _googleMapController;
  CameraPosition _cameraPosition = CameraPosition(
    target: LatLng(49.137756, 10.876035),
    zoom: 16.0,
  );
  final EventMapViewModel _eventMapViewModel;
  final FeatureConverter _featureConverter;

  _EventMapState(this._eventMapViewModel, this._featureConverter);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Set<MapFeature<Polygon>>>(
      stream: _eventMapViewModel.observeMapFeatures()
          .asyncMap((featureCollection) => _featureConverter.convertPolygons(featureCollection, _onPolygonTapped)),
      builder: (buildContext, snapshot) {
        return GoogleMap(
          initialCameraPosition: _cameraPosition,
          myLocationEnabled: true,
          polygons: snapshot.data?.map((mapFeature) => mapFeature.geometry)?.toSet() ?? Set(),
          onMapCreated: _onMapCreated,
          onCameraMove: _onCameraMove,
        );
      });
  }

  void _onPolygonTapped(FeatureMetaData featureMetaData) {
    print("##### polygon tapped: ${featureMetaData.name}");
  }

  void _onMapCreated(GoogleMapController controller) {
    _googleMapController = controller;
  }

  void _onCameraMove(CameraPosition cameraPosition) {
    _cameraPosition = cameraPosition;
  }

}