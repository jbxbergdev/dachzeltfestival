import 'package:dachzeltfestival/i18n/locale_state.dart';
import 'package:dachzeltfestival/repository/authenticator.dart';
import 'package:dachzeltfestival/repository/charity_repo.dart';
import 'package:dachzeltfestival/repository/config_repo.dart';
import 'package:dachzeltfestival/repository/legal_repo.dart';
import 'package:dachzeltfestival/repository/notification_repo.dart';
import 'package:dachzeltfestival/repository/permission_repo.dart';
import 'package:dachzeltfestival/view/charity/charity_viewmodel.dart';
import 'package:dachzeltfestival/view/legal/legal_viewmodel.dart';
import 'package:dachzeltfestival/view/main_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
  MapDataRepo mapDataRepo(Firestore firestore, FirebaseStorage firebaseStorage, Authenticator authenticator, LocaleState localeState)  =>
      MapDataRepoImpl(firestore, firebaseStorage, authenticator, localeState);

  @provide
  EventMapViewModel eventMapViewModel(MapDataRepo mapDataRepo, PermissionRepo permissionRepo) => EventMapViewModel(mapDataRepo, permissionRepo);

  @provide
  @singleton
  ScheduleRepo scheduleRepo(Firestore firestore, Authenticator authenticator, LocaleState localeState) => ScheduleRepoImpl(firestore, authenticator, localeState);

  @provide
  ScheduleViewModel scheduleViewModel(ScheduleRepo scheduleRepo) => ScheduleViewModel(scheduleRepo);

  @provide
  @singleton
  ConfigRepo configRepo(Firestore firestore, Authenticator authenticator, LocaleState localeState) => ConfigRepoImpl(firestore, authenticator, localeState);

  @provide
  MainViewModel mainViewModel(ConfigRepo configRepo, PermissionRepo permissionRepo, NotificationRepo notificationRepo) => MainViewModel(configRepo, permissionRepo, notificationRepo);

  @provide
  @singleton
  CharityRepo charityRepo(Firestore firestore, Authenticator authenticator, LocaleState localeState) => CharityRepoImpl(firestore, authenticator, localeState);

  @provide
  CharityViewModel charityViewModel(CharityRepo charityRepo) => CharityViewModel(charityRepo);

  @provide
  @singleton
  LegalRepo legalRepo(LocaleState localeState) => LegalRepoImpl(localeState);

  @provide
  LegalViewModel legalViewModel(LegalRepo legalRepo) => LegalViewModel(legalRepo);

  @provide
  @singleton
  PermissionRepo permissionRepo() => PermissionRepoImpl();

  @provide
  @singleton
  NotificationRepo notificationRepo(FirebaseMessaging firebaseMessaging, LocaleState localeState) => NotificationRepoImpl(firebaseMessaging, localeState);

  @provide
  @singleton
  LocaleState localeState() => LocaleState();

  @provide
  FirebaseMessaging firebaseMessaging() => FirebaseMessaging();

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