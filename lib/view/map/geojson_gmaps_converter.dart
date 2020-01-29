import 'dart:collection';
import 'dart:math';

import 'package:dachzeltfestival/model/geojson/point_category.dart';
import 'package:dachzeltfestival/util/utils.dart';
import 'package:dachzeltfestival/view/map/point_category_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as googlemaps;
import 'package:dachzeltfestival/model/geojson/feature.dart';
import 'package:inject/inject.dart';
import 'package:rxdart/rxdart.dart';

@provide
class FeatureConverter {

  static const int POLYGON_Z_INDEX = 0;
  static const double MARKER_Z_INDEX = 1;
  static const double SELECTED_MARKER_Z_INDEX = 2;

  final PointCategoryIcons _markerIconGenerator;

  FeatureConverter(this._markerIconGenerator);

  Future<GoogleMapsFeatures> parseFeatureCollection(FeatureCollection featureCollection, String selectedPlaceId, Function(Feature) onPolygonTap, Function(Feature) onMarkerTap) {
    return Observable.combineLatest4(_parsePolygons(featureCollection, selectedPlaceId, onPolygonTap).asStream(),
        _parseMarkers(featureCollection, selectedPlaceId, onMarkerTap).asStream(),
        _calculatePolygonBoundingBoxes(featureCollection).asStream(),
        _mapPointCoordinates(featureCollection).asStream(),
        (polygons, markers, boundingBoxMap, coordinatesMap) => GoogleMapsFeatures(polygons, markers, boundingBoxMap, coordinatesMap)).first;
  }

  Future<Set<googlemaps.Polygon>> _parsePolygons(FeatureCollection featureCollection, String selectedPlaceId, Function(Feature) onPolygonTap) async {
    int i = 0;
    return (featureCollection.features
      .where((feature) => feature is Polygon))
        .map((feature) {
      final polygon = feature as Polygon;
      final isSelected = selectedPlaceId != null && polygon.properties.placeId == selectedPlaceId;
      return googlemaps.Polygon(
        polygonId: googlemaps.PolygonId((i++).toString()),
        strokeColor: hexToColor(feature.properties?.stroke),
        fillColor: hexToColor(feature.properties?.fill).withOpacity(isSelected ? 1.0 : 0.5),
        strokeWidth: isSelected ? 10 : 2,
        points: polygon.coordinates[0].map((coordinates) => googlemaps.LatLng(coordinates.lat, coordinates.lng)).toList(),
        consumeTapEvents: true,
        zIndex: POLYGON_Z_INDEX,
        onTap: () => onPolygonTap(polygon),
      );
    }).toSet();
  }

  Future<Set<googlemaps.Marker>> _parseMarkers(FeatureCollection featureCollection, String selectedPlaceId, Function(Feature) onMarkerTap) async {
    final bitmaps = await _markerIconGenerator.bitmapMapping;
    int i = 0;
    return (featureCollection.features
      .where((feature) => feature is Point))
        .map((feature) {
          final point = feature as Point;
          final isSelected = selectedPlaceId != null && point.properties.placeId == selectedPlaceId;
          SelectionBitmapDescriptors descriptors = bitmaps[point.properties.pointCategory];
          return googlemaps.Marker(
             markerId: googlemaps.MarkerId((i++).toString()),
             position: point.toGmapsCoordinates(),
             icon: isSelected ? descriptors.selected : descriptors.unselected,
             consumeTapEvents: true,
             visible: true,
             zIndex: isSelected ? SELECTED_MARKER_Z_INDEX : MARKER_Z_INDEX,
             onTap: () => onMarkerTap(point),
           );
    }).toSet();
  }

  Future<Map<String, googlemaps.LatLngBounds>> _calculatePolygonBoundingBoxes(FeatureCollection featureCollection) async {
    return HashMap.fromIterable(featureCollection.features.where((feature) => feature is Polygon),
      key: (feature) => (feature as Polygon).properties.placeId, value: (feature) => (feature as Polygon).boundingBox());
  }

  Future<Map<String, googlemaps.LatLng>> _mapPointCoordinates(FeatureCollection featureCollection) async {
    return HashMap.fromIterable(featureCollection.features.where((feature) => feature is Point),
        key: (feature) => (feature as Point).properties.placeId, value: (feature) => (feature as Point).toGmapsCoordinates());
  }

}

class GoogleMapsFeatures {

  final Set<googlemaps.Polygon> polygons;
  final Set<googlemaps.Marker> markers;
  final Map<String, googlemaps.LatLngBounds> polygonBoundingBoxes;
  final Map<String, googlemaps.LatLng> pointCoordinates;

  GoogleMapsFeatures(this.polygons, this.markers, this.polygonBoundingBoxes, this.pointCoordinates);
}

extension on Point {
  googlemaps.LatLng toGmapsCoordinates() => googlemaps.LatLng(this.coordinates.lat, this.coordinates.lng);
}

extension on Polygon {

  googlemaps.LatLngBounds boundingBox() {

    double north = -90.0;
    double south = 90.0;
    double west = 180.0;
    double east = -180.0;

    this.coordinates.forEach((coordinates) {
      coordinates.forEach( (latLng) {
        north = max(north, latLng.lat);
        south = min(south, latLng.lat);
        west = min(west, latLng.lng);
        east = max(east, latLng.lng);
      });
    });

    // in case there is an event somewhere in the Pacific
    if (east - west > 180.0) {
      final tempWest = west;
      west = east;
      east = tempWest;
    }

    return googlemaps.LatLngBounds(northeast: googlemaps.LatLng(north, east), southwest: googlemaps.LatLng(south, west));
  }
}
