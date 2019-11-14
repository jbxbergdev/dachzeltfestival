import 'package:dachzeltfestival/repository/authenticator.dart';
import 'package:dachzeltfestival/repository/charity_repo.dart';
import 'package:dachzeltfestival/repository/config_repo.dart';
import 'package:dachzeltfestival/repository/permission_repo.dart';
import 'package:dachzeltfestival/view/charity/charity_viewmodel.dart';
import 'package:dachzeltfestival/view/main_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  @singleton
  MapDataRepo mapDataRepo(Firestore firestore, FirebaseStorage firebaseStorage, Authenticator authenticator)  =>  MapDataRepoImpl(firestore, firebaseStorage, authenticator);

  @provide
  EventMapViewModel eventMapViewModel(MapDataRepo mapDataRepo, PermissionRepo permissionRepo) => EventMapViewModel(mapDataRepo, permissionRepo);

  @provide
  @singleton
  ScheduleRepo scheduleRepo(Firestore firestore, Authenticator authenticator) => ScheduleRepoImpl(firestore, authenticator);

  @provide
  ScheduleViewModel scheduleViewModel(ScheduleRepo scheduleRepo) => ScheduleViewModel(scheduleRepo);

  @provide
  @singleton
  ConfigRepo configRepo(Firestore firestore, Authenticator authenticator) => ConfigRepoImpl(firestore, authenticator);

  @provide
  MainViewModel mainViewModel(ConfigRepo configRepo, PermissionRepo permissionRepo) => MainViewModel(configRepo, permissionRepo);

  @provide
  @singleton
  CharityRepo charityRepo(Firestore firestore, Authenticator authenticator) => CharityRepoImpl(firestore, authenticator);

  @provide
  CharityViewModel charityViewModel(CharityRepo charityRepo) => CharityViewModel(charityRepo);

  @provide
  @singleton
  PermissionRepo permissionRepo() => PermissionRepoImpl();

  @provide
  Firestore firestore() => Firestore.instance;

  @provide
  FirebaseStorage firebaseStorage() => FirebaseStorage.instance;

  @provide
  FirebaseAuth firebaseAuth() => FirebaseAuth.instance;

  @provide
  @singleton
  Authenticator authenticator(FirebaseAuth firebaseAuth) => AuthenticatorImpl(firebaseAuth);
}