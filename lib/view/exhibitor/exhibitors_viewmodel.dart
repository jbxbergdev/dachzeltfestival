
import 'package:dachzeltfestival/model/geojson/feature.dart';
import 'package:dachzeltfestival/repository/mapdata_repo.dart';
import 'package:dachzeltfestival/model/geojson/place_category.dart';
import 'package:inject/inject.dart';

@provide
class ExhibitorsViewModel {

  final MapDataRepo _mapDataRepo;

  ExhibitorsViewModel(this._mapDataRepo);

  Stream<List<Feature>> exhibitors() => _mapDataRepo.exhibitors().map((list) => list.premiumFirst());

}

extension on List<Feature> {
  List<Feature> premiumFirst() => this..sort((left, right) {
      if (left.properties.mappedCategory == right.properties.mappedCategory) {
        return left.properties.name.toUpperCase().compareTo(right.properties.name.toUpperCase());
      }
      return right.properties.mappedCategory == PlaceCategory.PREMIUM_EXHIBITOR ? 1 : -1;
    });
}