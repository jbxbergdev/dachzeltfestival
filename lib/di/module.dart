import 'package:inject/inject.dart';
import 'package:dachzeltfestival/repository/mapdata_repo.dart';
import 'package:dachzeltfestival/repository/dao/mapdata_dao.dart';
import 'package:dachzeltfestival/view/map/eventmap_viewmodel.dart';
import 'package:dachzeltfestival/repository/schedule_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dachzeltfestival/view/schedule/schedule_viewmodel.dart';

@module
class AppModule {

  @provide
  MapDataDao mapDataDao() => MapDataDaoImpl();

  @provide
  MapDataRepo mapDataRepo(MapDataDao mapDataDao)  =>  MapDataRepoImpl(mapDataDao);

  @provide
  EventMapViewModel eventMapViewModel(MapDataRepo mapDataRepo) => EventMapViewModel(mapDataRepo);


  @provide
  Firestore firestore() => Firestore.instance;

  @provide
  ScheduleRepo scheduleRepo(Firestore firestore) => ScheduleRepoImpl(firestore);

  @provide
  ScheduleViewModel scheduleViewModel(ScheduleRepo scheduleRepo) => ScheduleViewModel(scheduleRepo);

}