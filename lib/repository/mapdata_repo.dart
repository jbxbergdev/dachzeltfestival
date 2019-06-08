import 'package:dachzeltfestival/model/geojson/feature.dart';
import 'package:dachzeltfestival/repository/dao/mapdata_dao.dart';
import 'package:dachzeltfestival/model/map/map_position.dart';

abstract class MapDataRepo {
  Stream<FeatureCollection> observeFeatures();
}

class MapDataRepoImpl extends MapDataRepo {

  MapDataDao _mapDataDao = MapDataDaoImpl(); // TODO inject

  @override
  Stream<FeatureCollection> observeFeatures() async* {
    yield await _mapDataDao.readFeatures();
  }


}