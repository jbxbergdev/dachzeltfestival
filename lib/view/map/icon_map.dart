import 'package:dachzeltfestival/model/geojson/point_category.dart';
import 'package:flutter/material.dart';
import 'package:dachzeltfestival/util/custom_markers_icons.dart';

final Map<PointCategory, IconInfo> iconDataMap = {
  PointCategory.ENTRANCE: IconInfo(Icons.exit_to_app, Colors.black),
  PointCategory.FIREPIT: IconInfo(Icons.whatshot, Colors.red),
  PointCategory.FOOD: IconInfo(Icons.restaurant, Colors.deepOrange),
  PointCategory.INFO: IconInfo(Icons.info, Colors.green),
  PointCategory.MEDICAL: IconInfo(Icons.local_hospital, Colors.green),
  PointCategory.OFFICE: IconInfo(Icons.person, Colors.green),
  PointCategory.SHOWER: IconInfo(CustomMarkers.bathtub, Colors.blue),
  PointCategory.TOILET: IconInfo(Icons.wc, Colors.blue),
  PointCategory.INTERNET: IconInfo(Icons.wifi, Colors.black),
  PointCategory.CHARITY: IconInfo(Icons.favorite, Colors.red),
  PointCategory.HOT_TUB: IconInfo(Icons.hot_tub, Colors.red),
  PointCategory.ELECTRICITY: IconInfo(Icons.flash_on, Colors.orange),
  PointCategory.OTHER: IconInfo(Icons.place, Colors.black)
};

class IconInfo {
  final IconData icon;
  final Color color;

  IconInfo(this.icon, this.color);
}