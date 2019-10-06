import 'package:dachzeltfestival/repository/charity_repo.dart';
import 'package:dachzeltfestival/repository/config_repo.dart';
import 'package:dachzeltfestival/view/charity/charity_viewmodel.dart';
import 'package:dachzeltfestival/view/main_viewmodel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:inject/inject.dart';
import 'package:dachzeltfestival/repository/mapdata_repo.dart';
import 'package:dachzeltfestival/view/map/eventmap_viewmodel.dart';
import 'package:dachzeltfestival/repository/schedule_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dachzeltfestival/view/schedule/schedule_viewmodel.dart';

@module
class AppModule {

  @provide
  MapDataRepo mapDataRepo(Firestore firestore, FirebaseStorage firebaseStorage)  =>  MapDataRepoImpl(firestore, firebaseStorage);

  @provide
  EventMapViewModel eventMapViewModel(MapDataRepo mapDataRepo) => EventMapViewModel(mapDataRepo);

  @provide
  ScheduleRepo scheduleRepo(Firestore firestore) => ScheduleRepoImpl(firestore);

  @provide
  ScheduleViewModel scheduleViewModel(ScheduleRepo scheduleRepo) => ScheduleViewModel(scheduleRepo);

  @provide
  ConfigRepo configRepo(Firestore firestore) => ConfigRepoImpl(firestore);

  @provide
  MainViewModel mainViewModel(ConfigRepo configRepo) => MainViewModel(configRepo);

  @provide
  CharityRepo charityRepo(Firestore firestore) => CharityRepoImpl(firestore);

  @provide
  CharityViewModel charityViewModel(CharityRepo charityRepo) => CharityViewModel(charityRepo);

  @provide
  Firestore firestore() => Firestore.instance;

  @provide
  FirebaseStorage firebaseStorage() => FirebaseStorage.instance;
}