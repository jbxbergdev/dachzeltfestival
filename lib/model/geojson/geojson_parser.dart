import 'package:flutter/material.dart';

import 'feature.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as googlemaps;

class GeoJsonParser {
  static Future<FeatureCollection> parse() async {
    String jsonStr = await rootBundle.loadString('assets/raw/lageplan.json');
    FeatureCollection featureCollection = FeatureCollection.fromJson(json.decode(jsonStr));
    return featureCollection;
  }

  static Future<Set<googlemaps.Polygon>> parseGooglePolygons() async {
    FeatureCollection featureCollection = await parse();
    Set<googlemaps.Polygon> googlePolygons = Set();
    int i = 0;
    featureCollection.features.forEach((feature) {
      if (feature is Polygon) {
        googlemaps.Polygon googlePolygon = googlemaps.Polygon(
          polygonId: googlemaps.PolygonId((i++).toString()),
          strokeColor: hexToColor(feature.properties?.stroke),
          fillColor: hexToColor(feature.properties?.fill).withOpacity(0.3),
          strokeWidth: 2,
          points: feature.coordinates[0].map((coordinates) => googlemaps.LatLng(coordinates.lat, coordinates.lng)).toList(),
        );
        googlePolygons.add(googlePolygon);
      }
    });
    return googlePolygons;
  }

  static Color hexToColor(String code) {
    if (code == null) {
      return Colors.transparent;
    }
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }
}
