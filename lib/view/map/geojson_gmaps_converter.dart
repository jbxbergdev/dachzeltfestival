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

  static const double SELECTED_MARKER_Z_INDEX = 100;

  final PointCategoryIcons _markerIconGenerator;

  FeatureConverter(this._markerIconGenerator);

  Future<GoogleMapsGeometries> parseFeatureCollection(FeatureCollection featureCollection, int detailVisibility, Function(Feature) onPolygonTap, Function(Feature) onMarkerTap) {
    final start = DateTime.now();
    return Rx.combineLatest2(_parsePolygons(featureCollection, detailVisibility, onPolygonTap).asStream(),
        _parseMarkers(featureCollection, detailVisibility, onMarkerTap).asStream(),
        (polygons, markers) {
          print('##### parsing took ${DateTime.now().difference(start).inMilliseconds}ms');
          return GoogleMapsGeometries(polygons, markers);
        }).first;
  }

  Future<Set<_IdSet<googlemaps.Polygon>>> _parsePolygons(FeatureCollection featureCollection, int detailVisibility, Function(Feature) onPolygonTap) async {
    int i = 0;
    return featureCollection.features.where((feature) => feature is Polygon && (feature.properties?.detailLevel ?? 0) <= detailVisibility)
        .map((feature) {
          i++;
          final polygon = feature as Polygon;
          return _parsePolygonIdSet(polygon, googlemaps.PolygonId((i).toString()), i, onPolygonTap);
    }).toSet();
  }

  _IdSet<googlemaps.Polygon> _parsePolygonIdSet(Polygon polygon, googlemaps.PolygonId gmapsPolygonId, int zIndex, Function(Feature) onPolygonTap) {
    return _IdSet<googlemaps.Polygon>(
        polygon.properties.placeId,
        _parsePolygon(polygon, true, gmapsPolygonId, zIndex, onPolygonTap),
        _parsePolygon(polygon, false, gmapsPolygonId, zIndex, onPolygonTap));
  }

  googlemaps.Polygon _parsePolygon(Polygon polygon, bool selected, googlemaps.PolygonId gmapsPolygonId, int zIndex, Function(Feature) onPolygonTap) {
    return googlemaps.Polygon(
      polygonId: gmapsPolygonId,
      strokeColor: hexToColor(polygon.properties?.stroke),
      fillColor: hexToColor(polygon.properties?.fill).withOpacity(selected ? 1.0 : 0.5),
      strokeWidth: selected ? 10 : 2,
      points: polygon.coordinates[0].map((coordinates) => googlemaps.LatLng(coordinates.lat, coordinates.lng)).toList(),
      consumeTapEvents: true,
      zIndex: zIndex,
      onTap: () => onPolygonTap(polygon),
    );
  }

  Future<Set<_IdSet<googlemaps.Marker>>> _parseMarkers(FeatureCollection featureCollection, int detailVisibility, Function(Feature) onMarkerTap) async {
    final bitmaps = await _markerIconGenerator.bitmapMapping;
    int i = 0;
    double zIncrement = (SELECTED_MARKER_Z_INDEX - 1.0) / featureCollection.features.length.toDouble();
    return featureCollection.features.where((feature) => feature is Point && (feature.properties?.detailLevel ?? 0) <= detailVisibility)
        .map((feature) {
          double zIndex = i * zIncrement;
          final point = feature as Point;
          return _parseMarkerIdSet(point, googlemaps.MarkerId((i++).toString()), zIndex, onMarkerTap, bitmaps);
    }).toSet();
  }

  _IdSet<googlemaps.Marker> _parseMarkerIdSet(Point point, googlemaps.MarkerId markerId, double zIndex, Function(Feature) onMarkerTap, Map<PointCategory, SelectionBitmapDescriptors> bitmaps) {
    return _IdSet<googlemaps.Marker>(
      point.properties.placeId,
      _parseMarker(point, true, markerId, zIndex, onMarkerTap, bitmaps),
      _parseMarker(point, false, markerId, zIndex, onMarkerTap, bitmaps)
    );
  }

  googlemaps.Marker _parseMarker(Point point, bool selected, googlemaps.MarkerId markerId, double zIndex, Function(Feature) onMarkerTap, Map<PointCategory, SelectionBitmapDescriptors> bitmaps) {
    SelectionBitmapDescriptors descriptors = bitmaps[point.properties.pointCategory];
    return googlemaps.Marker(
      markerId: markerId,
      position: point.toGmapsCoordinates(),
      icon: selected ? descriptors.selected : descriptors.unselected,
      consumeTapEvents: true,
      visible: true,
      zIndex: selected ? SELECTED_MARKER_Z_INDEX : zIndex,
      onTap: () => onMarkerTap(point),
    );
  }

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