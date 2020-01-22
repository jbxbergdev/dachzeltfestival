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
  final BehaviorSubject<String> _selectedPlaceId = BehaviorSubject.seeded(null);

  EventMapViewModel(this._mapDataRepo, this._permissionRepo, this._placeSelectionInteractor);

  Observable<MapData> mapData() {
    final latestSelectedId = Observable.merge(<Stream<String>>[_placeSelectionInteractor.selectedPlaceId, _selectedPlaceId]);
    return Observable.combineLatest4(_mapDataRepo.mapFeatures(), _mapDataRepo.mapConfig(), _permissionRepo.locationPermissionState, latestSelectedId,
        (mapFeatures, mapConfig, locationPermissionGranted, selectedPlaceId) => MapData(mapFeatures, locationPermissionGranted, mapConfig, selectedPlaceId));
  }

  Sink<String> get selectedFeatureId => _selectedPlaceId.sink;

  Observable<String> get zoomToFeatureId => _placeSelectionInteractor.selectedPlaceId;
}

class MapData {
  final FeatureCollection mapFeatures;
  final bool locationPermissionGranted;
  final MapConfig mapConfig;
  final String selectedPlaceId;

  MapData(this.mapFeatures, this.locationPermissionGranted, this.mapConfig, this.selectedPlaceId);
}