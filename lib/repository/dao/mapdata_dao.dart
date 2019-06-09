import 'package:dachzeltfestival/model/geojson/feature.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';


abstract class MapDataDao {
  Future<FeatureCollection> readFeatures();
  void writeFeatures(FeatureCollection featureCollection);
}

class MapDataDaoImpl extends MapDataDao {

  @override
  Future<FeatureCollection> readFeatures() async {
    return rootBundle.loadString('assets/raw/lageplan.json')
        .then((jsonStr) => compute(_parseFeaturesFromJson, jsonStr));
  }

  @override
  void writeFeatures(FeatureCollection featureCollection) {
    // TODO: implement writeFeatures
  }

}

Future<FeatureCollection> _parseFeaturesFromJson(String jsonStr) async {
  return FeatureCollection.fromJson(json.decode(jsonStr));
}


