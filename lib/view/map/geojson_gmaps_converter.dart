import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as googlemaps;
import 'package:dachzeltfestival/model/geojson/feature.dart';
import 'package:inject/inject.dart';

@provide
class FeatureConverter {
  Future<Set<googlemaps.Polygon>> parseFeatureCollection(FeatureCollection featureCollection, Function(Properties) onPolygonTap) async {
    int i = 0;
    return (featureCollection.features
      ..retainWhere((feature) => feature is Polygon))
        .map((feature) {
          Polygon polygon = feature as Polygon;
          return googlemaps.Polygon(
            polygonId: googlemaps.PolygonId((i++).toString()),
            strokeColor: _hexToColor(feature.properties?.stroke),
            fillColor: _hexToColor(feature.properties?.fill).withOpacity(0.5),
            strokeWidth: 2,
            points: polygon.coordinates[0].map((coordinates) => googlemaps.LatLng(coordinates.lat, coordinates.lng)).toList(),
            consumeTapEvents: true,
            onTap: () => onPolygonTap(polygon.properties),
          );
        }).toSet();
  }

  Color _hexToColor(String code) {
    if (code == null) {
      return Colors.transparent;
    }
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }
}
