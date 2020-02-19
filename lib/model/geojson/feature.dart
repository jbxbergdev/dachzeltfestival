import 'translatable_json.dart';

class FeatureCollection {
  FeatureCollection({this.features});
  List<Feature> features;

  factory FeatureCollection.fromJson(Map<String, dynamic> json, String languageCode) {
    var featureList = json['features'] as List;
    List<Feature> features = featureList.map((it) => Feature.fromJson(it, languageCode)).toList();
    return FeatureCollection(features: features);
  }
}

class Feature {
  Properties properties;
  Feature({this.properties});
  factory Feature.fromJson(Map<String, dynamic> json, String languageCode) {
    Map<String, dynamic> geometry = json['geometry'];
    Properties properties = Properties.fromJson(json['properties'], languageCode);
    String type = geometry['type'];
    switch (type) {
      case 'Point':
        return Point.fromJson(geometry, properties);
      case 'LineString':
        return LineString.fromJson(geometry, properties);
      case 'Polygon':
        return Polygon.fromJson(geometry, properties);
    }
    return null;
  }
}

class LineString extends Feature {
  LineString({properties, this.coordinates}): super(properties: properties);
  List<Coordinates> coordinates;
  factory LineString.fromJson(Map<String, dynamic> json, Properties properties) {
    var coordinatesList = json['coordinates'] as List;
    return LineString(
      properties: properties,
      coordinates: coordinatesList.map((it) => Coordinates.fromJson(it)).toList()
    );
  }
}

class Polygon extends Feature {
  Polygon({properties, this.coordinates}): super(properties: properties);
  List<List<Coordinates>> coordinates;
  factory Polygon.fromJson(Map<String, dynamic> json, Properties properties) {
    var jsonListOfCoordinatesLists = json['coordinates'] as List;
    var listOfCoordinatesLists = jsonListOfCoordinatesLists.map((coordinatesList) =>
      (coordinatesList as List).map((jsonCoordinates) =>
          Coordinates.fromJson(jsonCoordinates)
      ).toList()
    ).toList();
    return Polygon(
        properties: properties,
        coordinates: listOfCoordinatesLists
    );
  }
}

class Point extends Feature {
  Point({properties, this.coordinates}): super(properties: properties);
  Coordinates coordinates;
  factory Point.fromJson(Map<String, dynamic> json, Properties properties) {
    return Point(
        properties: properties,
        coordinates: Coordinates.fromJson(json['coordinates'],
        ));
  }
}

class Coordinates {
  Coordinates({this.lng, this.lat});
  double lng;
  double lat;
  factory Coordinates.fromJson(dynamic json) {
    var coordinatesList = new List<num>.from(json);
    return Coordinates(lng: coordinatesList[0], lat: coordinatesList[1]);
  }
}

class Properties {
  String name;
  String description;
  String stroke;
  String fill;
  String placeId;
  String placeCategory;
  String url;
  String imageUrl;
  String logoUrl;
  int detailLevel;
  Properties({this.name, this.description, this.stroke, this.fill, this.placeId, this.placeCategory, this.detailLevel, this.url, this.imageUrl, this.logoUrl});
  factory Properties.fromJson(Map<String, dynamic> json, String languageCode) {
    return Properties(
      name: json.translated('name', languageCode),
      description: json.translated('description', languageCode),
      stroke: json['stroke'],
      fill: json['fill'],
      placeId: json['place_id'],
      placeCategory: json['place_category'],
      detailLevel: json['detail_level'],
      url: json['url'],
      imageUrl: json['image_url'],
      logoUrl: json['logo_url'],
    );
  }
}