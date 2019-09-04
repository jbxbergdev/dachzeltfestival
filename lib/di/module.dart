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
  Firestore firestore() => Firestore.instance;

  @provide
  FirebaseStorage firebaseStorage() => FirebaseStorage.instance;

  @provide
  ScheduleRepo scheduleRepo(Firestore firestore) => ScheduleRepoImpl(firestore);

  @provide
  ScheduleViewModel scheduleViewModel(ScheduleRepo scheduleRepo) => ScheduleViewModel(scheduleRepo);

}