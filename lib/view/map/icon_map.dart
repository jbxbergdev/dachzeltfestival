import 'package:dachzeltfestival/model/geojson/place_category.dart';
import 'package:flutter/material.dart';
import 'package:dachzeltfestival/util/custom_markers_icons.dart';

final Map<PlaceCategory, IconInfo> iconDataMap = {
  PlaceCategory.ENTRANCE: IconInfo(Icons.exit_to_app, Colors.black),
  PlaceCategory.FIREPIT: IconInfo(Icons.whatshot, Colors.red),
  PlaceCategory.FOOD: IconInfo(Icons.restaurant, Colors.deepOrange),
  PlaceCategory.INFO: IconInfo(Icons.info, Colors.green),
  PlaceCategory.MEDICAL: IconInfo(Icons.local_hospital, Colors.green),
  PlaceCategory.OFFICE: IconInfo(Icons.person, Colors.green),
  PlaceCategory.SHOWER: IconInfo(CustomMarkers.bathtub, Colors.blue),
  PlaceCategory.TOILET: IconInfo(Icons.wc, Colors.blue),
  PlaceCategory.INTERNET: IconInfo(Icons.wifi, Colors.black),
  PlaceCategory.CHARITY: IconInfo(Icons.favorite, Colors.red),
  PlaceCategory.HOT_TUB: IconInfo(Icons.hot_tub, Colors.red),
  PlaceCategory.ELECTRICITY: IconInfo(Icons.flash_on, Colors.orange),
  PlaceCategory.OTHER: IconInfo(Icons.place, Colors.black)
};

class IconInfo {
  final IconData icon;
  final Color color;

  IconInfo(this.icon, this.color);
}