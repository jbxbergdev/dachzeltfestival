
import 'package:dachzeltfestival/model/geojson/feature.dart';
import 'package:dachzeltfestival/repository/mapdata_repo.dart';
import 'package:inject/inject.dart';

@provide
class ExhibitorsViewModel {

  final MapDataRepo _mapDataRepo;

  ExhibitorsViewModel(this._mapDataRepo);

  Stream<List<Feature>> exhibitors() => _mapDataRepo.exhibitors();

}