import 'feature.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class GeoJsonParser {
  static Future<FeatureCollection> parse() async {
    String jsonStr = await rootBundle.loadString('assets/raw/lageplan.json');
    FeatureCollection featureCollection = FeatureCollection.fromJson(json.decode(jsonStr));
    return featureCollection;
  }
}
