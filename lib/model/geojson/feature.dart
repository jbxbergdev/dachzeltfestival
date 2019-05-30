import 'package:flutter/foundation.dart';

class FeatureCollection {
  FeatureCollection({this.features});
  List<Feature> features;

  factory FeatureCollection.fromJson(Map<String, dynamic> json) {
    var featureList = json['features'] as List;
    List<Feature> features = featureList.map((it) => Feature.fromJson(it)).toList();
    return FeatureCollection(features: features);
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
    }
    return null;
  }
}

class LineString extends Feature {

}

class Polygon extends Feature {

}

class Point extends Feature {
  Point({this.coordinates});
  Coordinates coordinates;
  factory Point.fromJson(Map<String, dynamic> json) {
    var coordinatesFromJson = json['coordinates'];
    List<num> coordsList = new List<num>.from(coordinatesFromJson);
    return Point(coordinates: Coordinates(lng: coordsList[0], lat: coordsList[1]));
  }
}

class Coordinates {
  Coordinates({this.lng, this.lat});
  double lng;
  double lat;
}

class Properties {

}