import 'package:dachzeltfestival/util/utils.dart';
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
            strokeColor: hexToColor(feature.properties?.stroke),
            fillColor: hexToColor(feature.properties?.fill).withOpacity(0.5),
            strokeWidth: 2,
            points: polygon.coordinates[0].map((coordinates) => googlemaps.LatLng(coordinates.lat, coordinates.lng)).toList(),
            consumeTapEvents: true,
            onTap: () => onPolygonTap(polygon.properties),
          );
        }).toSet();
  }
}
