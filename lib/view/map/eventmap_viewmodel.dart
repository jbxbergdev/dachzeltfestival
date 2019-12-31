import 'package:dachzeltfestival/model/configuration/map_config.dart';
import 'package:dachzeltfestival/model/geojson/feature.dart';
import 'package:dachzeltfestival/repository/mapdata_repo.dart';
import 'package:dachzeltfestival/repository/permission_repo.dart';
import 'package:inject/inject.dart';
import 'package:rxdart/rxdart.dart';

@provide
class EventMapViewModel {

  final MapDataRepo _mapDataRepo;
  final PermissionRepo _permissionRepo;

  EventMapViewModel(this._mapDataRepo, this._permissionRepo);

  Observable<MapData> mapData() {
    return Observable.combineLatest4(_mapDataRepo.mapFeatures(), _mapDataRepo.mapConfig(), _permissionRepo.locationPermissionState, selectedPlaceId,
        (mapFeatures, mapConfig, locationPermissionGranted, selectedPlaceId) => MapData(mapFeatures, locationPermissionGranted, mapConfig, selectedPlaceId));
  }

  BehaviorSubject<String> selectedPlaceId = BehaviorSubject.seeded(null);
}

class MapData {
  final FeatureCollection mapFeatures;
  final bool locationPermissionGranted;
  final MapConfig mapConfig;
  final String selectedPlaceId;

  MapData(this.mapFeatures, this.locationPermissionGranted, this.mapConfig, this.selectedPlaceId);
}