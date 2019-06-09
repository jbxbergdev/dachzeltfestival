import 'package:dachzeltfestival/model/geojson/feature.dart';
import 'package:dachzeltfestival/repository/dao/mapdata_dao.dart';

abstract class MapDataRepo {
  Stream<FeatureCollection> observeFeatures();
}

class MapDataRepoImpl extends MapDataRepo {

  MapDataDao _mapDataDao;

  MapDataRepoImpl(this._mapDataDao);

  @override
  Stream<FeatureCollection> observeFeatures() async* {
    yield await _mapDataDao.readFeatures();
  }


}