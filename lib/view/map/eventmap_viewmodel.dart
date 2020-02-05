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

  Stream<FeatureCollection> features() => _mapDataRepo.mapFeatures();

  Stream<bool> locationPermissionGranted() => _permissionRepo.locationPermissionState;

  Stream<MapConfig> mapConfig() => _mapDataRepo.mapConfig();

  Stream<String> get zoomToFeatureId => _placeSelectionInteractor.selectedPlaceId;

  Future<void> zoomHandled() async => _placeSelectionInteractor.selectedPlaceId.add(null);
}