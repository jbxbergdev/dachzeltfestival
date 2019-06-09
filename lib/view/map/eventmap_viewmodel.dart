import 'package:dachzeltfestival/model/geojson/feature.dart';
import 'package:dachzeltfestival/repository/mapdata_repo.dart';
import 'package:inject/inject.dart';

@provide
class EventMapViewModel {

  MapDataRepo _mapDataRepo;

  EventMapViewModel(this._mapDataRepo);

  Stream<FeatureCollection> observeMapFeatures() {
    return _mapDataRepo.observeFeatures();
  }
}