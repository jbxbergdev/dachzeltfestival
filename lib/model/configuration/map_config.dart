import 'package:dachzeltfestival/model/geojson/feature.dart';

class MapConfig {
  final Coordinates initalMapCenter;
  final double initialZoomLevel;
  final Coordinates navDestination;
  final int mapVersion;
  final String mapUrl;
  final bool isSingleLocationEvent;

  MapConfig({this.initalMapCenter, this.initialZoomLevel, this.navDestination, this.mapVersion, this.mapUrl, this.isSingleLocationEvent});
}