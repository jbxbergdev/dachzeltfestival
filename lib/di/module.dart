import 'package:inject/inject.dart';
import 'package:dachzeltfestival/repository/mapdata_repo.dart';
import 'package:dachzeltfestival/repository/dao/mapdata_dao.dart';
import 'package:dachzeltfestival/view/map/eventmap_viewmodel.dart';

@module
class AppModule {

  @provide
  MapDataDao mapDataDao() => MapDataDaoImpl();

  @provide
  MapDataRepo mapDataRepo(MapDataDao mapDataDao)  =>  MapDataRepoImpl(mapDataDao);

  @provide
  EventMapViewModel eventMapViewModel(MapDataRepo mapDataRepo) => EventMapViewModel(mapDataRepo);

}