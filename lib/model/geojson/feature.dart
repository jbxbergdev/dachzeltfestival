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
      name: /*json.translated('name', languageCode)*/ 'iKamper lalalalalal alaalalala lalalall',
      description: /*json.translated('description', languageCode) */ _loremIpsum,
      stroke: json['stroke'],
      fill: json['fill'],
      placeId: json['place_id'],
      placeCategory: json['place_category'],
      detailLevel: json['detail_level'],
      url: /*json['url']*/ 'https://dachzeltnomaden.com',
      imageUrl: /*json['image_url']*/"https://dachzeltnomaden.com/wp-content/uploads/2020/01/20190518-DZF-reportrage-KatjaSeidel_DSC6075-1024x681.jpg",
      logoUrl: /*json['logo_url']*/'https://dachzeltnomaden.com/wp-content/uploads/2017/11/dachzeltnomaden_dachzelt_hersteller_logo-300x74.png',
    );
  }
}

const _loremIpsum = """Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?

At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat.""";