import 'package:dachzeltfestival/model/geojson/feature.dart';

enum  PlaceCategory {
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
  PREMIUM_EXHIBITOR,
  OTHER
}

extension CategoryMapper on Properties {
  PlaceCategory get mappedCategory {
    switch (this.placeCategory) {
      case 'toilet':
        return PlaceCategory.TOILET;
      case 'shower':
        return PlaceCategory.SHOWER;
      case 'entrance':
        return PlaceCategory.ENTRANCE;
      case 'info':
        return PlaceCategory.INFO;
      case 'medical':
        return PlaceCategory.MEDICAL;
      case 'food':
        return PlaceCategory.FOOD;
      case 'firepit':
        return PlaceCategory.FIREPIT;
      case 'office':
        return PlaceCategory.OFFICE;
      case 'internet':
        return PlaceCategory.INTERNET;
      case 'hot_tub':
        return PlaceCategory.HOT_TUB;
      case 'charity':
        return PlaceCategory.CHARITY;
      case 'electricity':
        return PlaceCategory.ELECTRICITY;
      case 'exhibitor':
        return PlaceCategory.EXHIBITOR;
      case 'premium_exhibitor':
        return PlaceCategory.PREMIUM_EXHIBITOR;
      default:
        return PlaceCategory.OTHER;
    }
  }
}
