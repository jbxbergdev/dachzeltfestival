import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'eventmap_viewmodel.dart';
import 'geojson_gmaps_converter.dart';


class EventMap extends StatefulWidget {

  EventMap({Key key}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EventMapState(EventMapViewModel()); // TODO inject EventMapViewModel
  }
}

class _EventMapState extends State<EventMap> {

  GoogleMapController _googleMapController;
  CameraPosition _cameraPosition = CameraPosition(
    target: LatLng(49.137756, 10.876035),
    zoom: 16.0,
  );
  EventMapViewModel _eventMapViewModel;

  _EventMapState(this._eventMapViewModel);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Set<Polygon>>(
      // TODO inject FeatureConverter
      stream: _eventMapViewModel.observeMapFeatures()
          .asyncMap((featureCollection) => FeatureConverter().convertPolygons(featureCollection)),
      builder: (buildContext, snapshot) {
        return GoogleMap(
          initialCameraPosition: _cameraPosition,
          myLocationEnabled: true,
          polygons: snapshot.data ?? Set(),
          onMapCreated: _onMapCreated,
          onCameraMove: _onCameraMove,
        );
      });
  }

  void _onMapCreated(GoogleMapController controller) {
    _googleMapController = controller;
  }

  void _onCameraMove(CameraPosition cameraPosition) {
    _cameraPosition = cameraPosition;
  }

}