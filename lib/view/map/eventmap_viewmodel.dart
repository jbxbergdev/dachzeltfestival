import 'package:dachzeltfestival/model/geojson/feature.dart';
import 'package:dachzeltfestival/repository/mapdata_repo.dart';

class EventMapViewModel {

  MapDataRepo _mapDataRepo = MapDataRepoImpl(); // TODO inject

  Stream<FeatureCollection> observeMapFeatures() {
    return _mapDataRepo.observeFeatures();
  }
}