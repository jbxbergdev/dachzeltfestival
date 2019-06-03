import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dachzeltfestival/model/geojson/geojson_parser.dart';


class EventMap extends StatefulWidget {
  EventMap({Key key}): super(key: key) {
  }

  @override
  State<StatefulWidget> createState() {
    return _EventMapState();
  }
}

class _EventMapState extends State<EventMap> {

  Set<Polygon> _polygons = Set<Polygon>();
  GoogleMapController _googleMapController;
  CameraPosition _cameraPosition = CameraPosition(
    target: LatLng(49.137756, 10.876035),
    zoom: 16.0,
  );

  _EventMapState() {
    GeoJsonParser.parseGooglePolygons().then((polygons) {
      setState(() {
        this._polygons = polygons;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: _cameraPosition,
      myLocationEnabled: true,
      polygons: _polygons,
      onMapCreated: _onMapCreated,
      onCameraMove: _onCameraMove,
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _googleMapController = controller;
  }

  void _onCameraMove(CameraPosition cameraPosition) {
    _cameraPosition = cameraPosition;
  }

}