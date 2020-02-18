import 'package:dachzeltfestival/model/geojson/feature.dart';

enum  PointCategory {
  TOILET,
  SHOWER,
  ENTRANCE,
  INFO,
  MEDICAL,
  FOOD,
  FIREPIT,
  OFFICE,
  INTERNET,
  HOT_TUB,
  CHARITY,
  ELECTRICITY,
  EXHIBITOR,
  OTHER
}

extension CategoryMapper on Properties {
  PointCategory get pointCategory {
    switch (this.placeCategory) {
      case 'toilet':
        return PointCategory.TOILET;
      case 'shower':
        return PointCategory.SHOWER;
      case 'entrance':
        return PointCategory.ENTRANCE;
      case 'info':
        return PointCategory.INFO;
      case 'medical':
        return PointCategory.MEDICAL;
      case 'food':
        return PointCategory.FOOD;
      case 'firepit':
        return PointCategory.FIREPIT;
      case 'office':
        return PointCategory.OFFICE;
      case 'internet':
        return PointCategory.INTERNET;
      case 'hot_tub':
        return PointCategory.HOT_TUB;
      case 'charity':
        return PointCategory.CHARITY;
      case 'electricity':
        return PointCategory.ELECTRICITY;
      case 'exhibitor':
        return PointCategory.EXHIBITOR;
      default:
        return PointCategory.OTHER;
    }
  }
}
