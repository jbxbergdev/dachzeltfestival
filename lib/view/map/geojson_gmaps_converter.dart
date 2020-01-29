import 'dart:collection';
import 'dart:math';

import 'package:dachzeltfestival/model/geojson/point_category.dart';
import 'package:dachzeltfestival/util/utils.dart';
import 'package:dachzeltfestival/view/map/point_category_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as googlemaps;
import 'package:dachzeltfestival/model/geojson/feature.dart';
import 'package:inject/inject.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

@provide
class FeatureConverter {

  static const int POLYGON_Z_INDEX = 0;
  static const double MARKER_Z_INDEX = 1;
  static const double SELECTED_MARKER_Z_INDEX = 2;

  final PointCategoryIcons _markerIconGenerator;

  FeatureConverter(this._markerIconGenerator);

  Future<GoogleMapsGeometries> parseFeatureCollection(FeatureCollection featureCollection, Function(Feature) onPolygonTap, Function(Feature) onMarkerTap) {
    return Observable.combineLatest2(_parsePolygons(featureCollection, onPolygonTap).asStream(),
        _parseMarkers(featureCollection, onMarkerTap).asStream(),
        (polygons, markers) => GoogleMapsGeometries(polygons, markers)).first;
  }

  Future<Set<_IdSet<googlemaps.Polygon>>> _parsePolygons(FeatureCollection featureCollection, Function(Feature) onPolygonTap) async {
    int i = 0;
    return featureCollection.features.where((feature) => feature is Polygon)
        .map((feature) {
          final polygon = feature as Polygon;
          return _parsePolygonIdSet(polygon, googlemaps.PolygonId((i++).toString()), onPolygonTap);
    }).toSet();
  }

  _IdSet<googlemaps.Polygon> _parsePolygonIdSet(Polygon polygon, googlemaps.PolygonId gmapsPolygonId, Function(Feature) onPolygonTap) {
    return _IdSet<googlemaps.Polygon>(
        polygon.properties.placeId,
        _parsePolygon(polygon, true, gmapsPolygonId, onPolygonTap),
        _parsePolygon(polygon, false, gmapsPolygonId, onPolygonTap));
  }

  googlemaps.Polygon _parsePolygon(Polygon polygon, bool selected, googlemaps.PolygonId gmapsPolygonId, Function(Feature) onPolygonTap) {
    return googlemaps.Polygon(
      polygonId: gmapsPolygonId,
      strokeColor: hexToColor(polygon.properties?.stroke),
      fillColor: hexToColor(polygon.properties?.fill).withOpacity(selected ? 1.0 : 0.5),
      strokeWidth: selected ? 10 : 2,
      points: polygon.coordinates[0].map((coordinates) => googlemaps.LatLng(coordinates.lat, coordinates.lng)).toList(),
      consumeTapEvents: true,
      zIndex: POLYGON_Z_INDEX,
      onTap: () => onPolygonTap(polygon),
    );
  }

//  Future<Set<googlemaps.Polygon>> _parsePolygonsForSelectionState(FeatureCollection featureCollection, Function(Feature) onPolygonTap, bool selected) async {
//    int i = 0;
//    return (featureCollection.features
//      .where((feature) => feature is Polygon))
//        .map((feature) {
//      final polygon = feature as Polygon;
//      return googlemaps.Polygon(
//        polygonId: googlemaps.PolygonId((i++).toString()),
//        strokeColor: hexToColor(feature.properties?.stroke),
//        fillColor: hexToColor(feature.properties?.fill).withOpacity(selected ? 1.0 : 0.5),
//        strokeWidth: selected ? 10 : 2,
//        points: polygon.coordinates[0].map((coordinates) => googlemaps.LatLng(coordinates.lat, coordinates.lng)).toList(),
//        consumeTapEvents: true,
//        zIndex: POLYGON_Z_INDEX,
//        onTap: () => onPolygonTap(polygon),
//      );
//    }).toSet();
//  }

  Future<Set<_IdSet<googlemaps.Marker>>> _parseMarkers(FeatureCollection featureCollection, Function(Feature) onMarkerTap) async {
    final bitmaps = await _markerIconGenerator.bitmapMapping;
    int i = 0;
    return featureCollection.features.where((feature) => feature is Point)
        .map((feature) {
          final point = feature as Point;
          return _parseMarkerIdSet(point, googlemaps.MarkerId((i++).toString()), onMarkerTap, bitmaps);
    }).toSet();
  }

  _IdSet<googlemaps.Marker> _parseMarkerIdSet(Point point, googlemaps.MarkerId markerId, Function(Feature) onMarkerTap, Map<PointCategory, SelectionBitmapDescriptors> bitmaps) {
    return _IdSet<googlemaps.Marker>(
      point.properties.placeId,
      _parseMarker(point, true, markerId, onMarkerTap, bitmaps),
      _parseMarker(point, false, markerId, onMarkerTap, bitmaps)
    );
  }

  googlemaps.Marker _parseMarker(Point point, bool selected, googlemaps.MarkerId markerId, Function(Feature) onMarkerTap, Map<PointCategory, SelectionBitmapDescriptors> bitmaps) {
    SelectionBitmapDescriptors descriptors = bitmaps[point.properties.pointCategory];
    return googlemaps.Marker(
      markerId: markerId,
      position: point.toGmapsCoordinates(),
      icon: selected ? descriptors.selected : descriptors.unselected,
      consumeTapEvents: true,
      visible: true,
      zIndex: selected ? SELECTED_MARKER_Z_INDEX : MARKER_Z_INDEX,
      onTap: () => onMarkerTap(point),
    );
  }

//  Future<Set<googlemaps.Marker>> _parseMarkers(FeatureCollection featureCollection, String selectedPlaceId, Function(Feature) onMarkerTap) async {
//    final bitmaps = await _markerIconGenerator.bitmapMapping;
//    int i = 0;
//    return (featureCollection.features
//      .where((feature) => feature is Point))
//        .map((feature) {
//          final point = feature as Point;
//          final isSelected = selectedPlaceId != null && point.properties.placeId == selectedPlaceId;
//          SelectionBitmapDescriptors descriptors = bitmaps[point.properties.pointCategory];
//          return googlemaps.Marker(
//             markerId: googlemaps.MarkerId((i++).toString()),
//             position: point.toGmapsCoordinates(),
//             icon: isSelected ? descriptors.selected : descriptors.unselected,
//             consumeTapEvents: true,
//             visible: true,
//             zIndex: isSelected ? SELECTED_MARKER_Z_INDEX : MARKER_Z_INDEX,
//             onTap: () => onMarkerTap(point),
//           );
//    }).toSet();
//  }

}

class GoogleMapsGeometries {

  final Set<_IdSet<googlemaps.Polygon>> _polygons;
  final Set<_IdSet<googlemaps.Marker>> _markers;

  GoogleMapsGeometries(this._polygons, this._markers);

  Set<googlemaps.Polygon> polygons(String selected) => _polygons.map((idSet) => idSet.id == selected ? idSet.selected : idSet.unselected ).toSet();

  Set<googlemaps.Marker> markers(String selected) => _markers.map((idSet) => idSet.id == selected ? idSet.selected : idSet.unselected ).toSet();
}

class _IdSet<T> {
  Tuple3<String, T, T> _tuple;

  _IdSet(String id, T unselected, T selected) {
    _tuple = Tuple3(id, unselected, selected);
  }

  String get id => _tuple.item1;
  T get selected => _tuple.item2;
  T get unselected => _tuple.item3;
}

extension on Point {
  googlemaps.LatLng toGmapsCoordinates() => googlemaps.LatLng(this.coordinates.lat, this.coordinates.lng);
}
