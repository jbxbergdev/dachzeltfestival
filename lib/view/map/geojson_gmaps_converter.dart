import 'package:dachzeltfestival/model/geojson/point_category.dart';
import 'package:dachzeltfestival/util/utils.dart';
import 'package:dachzeltfestival/view/map/point_category_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as googlemaps;
import 'package:dachzeltfestival/model/geojson/feature.dart';
import 'package:inject/inject.dart';
import 'package:rxdart/rxdart.dart';

@provide
class FeatureConverter {

  final PointCategoryIcons _markerIconGenerator;

  FeatureConverter(this._markerIconGenerator);

  Future<GoogleMapsFeatures> parseFeatureCollection(FeatureCollection featureCollection, String selectedPlaceId, Function(Feature) onPolygonTap, Function(Feature) onMarkerTap) {
    return Observable.combineLatest2(_parsePolygons(featureCollection, selectedPlaceId, onPolygonTap).asStream(), _parseMarkers(featureCollection, selectedPlaceId, onMarkerTap).asStream(),
        (polygons, markers) => GoogleMapsFeatures(polygons, markers)).first;
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
             position: googlemaps.LatLng(point.coordinates.lat, point.coordinates.lng),
             icon: isSelected ? descriptors.selected : descriptors.unselected,
             consumeTapEvents: true,
             visible: true,
             onTap: () => onMarkerTap(point)
           );
    }).toSet();
  }
}

class GoogleMapsFeatures {
  final Set<googlemaps.Polygon> polygons;
  final Set<googlemaps.Marker> markers;

  GoogleMapsFeatures(this.polygons, this.markers);
}
