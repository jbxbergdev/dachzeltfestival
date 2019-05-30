import 'package:flutter/foundation.dart';

class FeatureCollection {
  FeatureCollection({this.features});
  List<Feature> features;

  factory FeatureCollection.fromJson(Map<String, dynamic> json) {
    var featureList = json['features'] as List;
    List<Feature> features = featureList.map((it) => Feature.fromJson(it)).toList();
    FeatureCollection featureCollection = FeatureCollection(features: features);
    featureCollection.features.forEach((feature) => print(feature));
    return featureCollection;
  }
}


class Feature {
  Feature();
  factory Feature.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> geometry = json['geometry'];
    String type = geometry['type'];
    switch (type) {
      case 'Point':
        return Point.fromJson(geometry);
      case 'LineString':
        return LineString.fromJson(geometry);
      case 'Polygon':
        return Polygon.fromJson(geometry);
    }
    return null;
  }
}

class LineString extends Feature {
  LineString({this.coordinates});
  List<Coordinates> coordinates;
  factory LineString.fromJson(Map<String, dynamic> json) {
    var coordinatesList = json['coordinates'] as List;
    return LineString(
      coordinates: coordinatesList.map((it) => Coordinates.fromJson(it)).toList()
    );
  }
}

class Polygon extends Feature {
  Polygon({this.coordinates});
  List<List<Coordinates>> coordinates;
  factory Polygon.fromJson(Map<String, dynamic> json) {
    var jsonListOfCoordinatesLists = json['coordinates'] as List;
    var listOfCoordinatesLists = jsonListOfCoordinatesLists.map((coordinatesList) =>
      (coordinatesList as List).map((jsonCoordinates) =>
          Coordinates.fromJson(jsonCoordinates)
      ).toList()
    ).toList();

    return Polygon(
        coordinates: listOfCoordinatesLists
    );
  }
}

class Point extends Feature {
  Point({this.coordinates});
  Coordinates coordinates;
  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(coordinates: Coordinates.fromJson(json['coordinates']));
  }
}

class Coordinates {
  Coordinates({this.lng, this.lat});
  double lng;
  double lat;
  factory Coordinates.fromJson(dynamic json) {
    print(json);
    var coordinatesList = new List<num>.from(json);
    return Coordinates(lng: coordinatesList[0], lat: coordinatesList[1]);
  }
}

class Properties {

}