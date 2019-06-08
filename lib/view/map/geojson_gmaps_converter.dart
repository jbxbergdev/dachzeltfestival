import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as googlemaps;
import 'package:dachzeltfestival/model/geojson/feature.dart';

class FeatureConverter {
  Future<Set<googlemaps.Polygon>> convertPolygons(FeatureCollection featureCollection) async {
    return compute(_convertPolygons, featureCollection);
  }
}

Future<Set<googlemaps.Polygon>> _convertPolygons(FeatureCollection featureCollection) async {
  Set<googlemaps.Polygon> googlePolygons = Set();
  int i = 0;
  featureCollection.features.forEach((feature) {
    if (feature is Polygon) {
      googlemaps.Polygon googlePolygon = googlemaps.Polygon(
        polygonId: googlemaps.PolygonId((i++).toString()),
        strokeColor: _hexToColor(feature.properties?.stroke),
        fillColor: _hexToColor(feature.properties?.fill).withOpacity(0.3),
        strokeWidth: 2,
        points: feature.coordinates[0].map((coordinates) => googlemaps.LatLng(coordinates.lat, coordinates.lng)).toList(),
      );
      googlePolygons.add(googlePolygon);
    }
  });
  return googlePolygons;
}

Color _hexToColor(String code) {
  if (code == null) {
    return Colors.transparent;
  }
  return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}