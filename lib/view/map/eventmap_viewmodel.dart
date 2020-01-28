import 'package:dachzeltfestival/model/configuration/map_config.dart';
import 'package:dachzeltfestival/model/geojson/feature.dart';
import 'package:dachzeltfestival/repository/mapdata_repo.dart';
import 'package:dachzeltfestival/repository/permission_repo.dart';
import 'package:dachzeltfestival/view/place_selection_interactor.dart';
import 'package:inject/inject.dart';
import 'package:rxdart/rxdart.dart';

@provide
class EventMapViewModel {

  final MapDataRepo _mapDataRepo;
  final PermissionRepo _permissionRepo;
  final PlaceSelectionInteractor _placeSelectionInteractor;

  EventMapViewModel(this._mapDataRepo, this._permissionRepo, this._placeSelectionInteractor);

  Observable<MapData> mapData() {
    print('##### mapData()');
    return Observable.combineLatest3(_mapDataRepo.mapFeatures().doOnData((_) => print('##### new map features')), _mapDataRepo.mapConfig().doOnData((_) => print('##### new map config')), _permissionRepo.locationPermissionState.doOnData((_) => print('##### new permission state')),
        (mapFeatures, mapConfig, locationPermissionGranted) => MapData(mapFeatures, locationPermissionGranted, mapConfig));
  }

  Observable<String> get zoomToFeatureId => _placeSelectionInteractor.selectedPlaceId;

  Future<void> zoomHandled() async => _placeSelectionInteractor.selectedPlaceId.add(null);
}

class MapData {
  final FeatureCollection mapFeatures;
  final bool locationPermissionGranted;
  final MapConfig mapConfig;

  MapData(this.mapFeatures, this.locationPermissionGranted, this.mapConfig);
}