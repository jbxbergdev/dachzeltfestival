import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';


class EventMap extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EventMapState();
  }
}

class _EventMapState extends State<EventMap> {

  Polygon polygon = Polygon(
      polygonId: PolygonId("testPolygon"),
      points: List<LatLng>()
        ..add(LatLng(52.499326, 13.412101))
        ..add(LatLng(52.499279, 13.412291))
        ..add(LatLng(52.498985, 13.412079))
        ..add(LatLng(52.499032, 13.411942))
        ..add(LatLng(52.499326, 13.412101)),
      fillColor: Color(0x40F02C02));
  Set<Polygon> polygons = Set<Polygon>();

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        polygons.clear();
        polygons.add(polygon);
      });
    });
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(52.499130, 13.412062),
        zoom: 16.0,
      ),
      myLocationEnabled: true,
      polygons: polygons,
    );
  }

}