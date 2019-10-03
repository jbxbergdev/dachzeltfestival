import 'dart:ui';

import 'package:dachzeltfestival/model/geojson/feature.dart';
import 'package:dachzeltfestival/repository/mapdata_repo.dart';
import 'package:inject/inject.dart';
import 'package:rxdart/rxdart.dart';

@provide
class EventMapViewModel {

  final MapDataRepo _mapDataRepo;

  EventMapViewModel(this._mapDataRepo);

  BehaviorSubject<Locale> get localeSubject {
    return _mapDataRepo.localeSubject;
  }

  Stream<FeatureCollection> observeMapFeatures() {
    return _mapDataRepo.observeFeatures();
  }
}