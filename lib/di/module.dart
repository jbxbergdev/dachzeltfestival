import 'dart:io';

import 'package:dachzeltfestival/repository/event_info_repo.dart';
import 'package:dachzeltfestival/repository/feed_repo.dart';
import 'package:dachzeltfestival/view/builders.dart';
import 'package:dachzeltfestival/i18n/locale_state.dart';
import 'package:dachzeltfestival/repository/authenticator.dart';
import 'package:dachzeltfestival/repository/charity_repo.dart';
import 'package:dachzeltfestival/repository/config_repo.dart';
import 'package:dachzeltfestival/repository/firebase_message_parser.dart';
import 'package:dachzeltfestival/repository/legal_repo.dart';
import 'package:dachzeltfestival/repository/notification_repo.dart';
import 'package:dachzeltfestival/repository/permission_repo.dart';
import 'package:dachzeltfestival/view/charity/charity_viewmodel.dart';
import 'package:dachzeltfestival/view/feed/feed_viewmodel.dart';
import 'package:dachzeltfestival/view/feedback/feedback_viewmodel.dart';
import 'package:dachzeltfestival/view/info/event_info_viewmodel.dart';
import 'package:dachzeltfestival/view/legal/legal_viewmodel.dart';
import 'package:dachzeltfestival/view/main_viewmodel.dart';
import 'package:dachzeltfestival/view/map/eventmap.dart';
import 'package:dachzeltfestival/view/notification/notification_list_viewmodel.dart';
import 'package:dachzeltfestival/view/place_selection_interactor.dart';
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
  EventMapViewModel eventMapViewModel(MapDataRepo mapDataRepo, PermissionRepo permissionRepo, PlaceSelectionInteractor placeSelectionInteractor) => EventMapViewModel(mapDataRepo, permissionRepo, placeSelectionInteractor);

  @provide
  @singleton
  ScheduleRepo scheduleRepo(Firestore firestore, Authenticator authenticator, LocaleState localeState, MapDataRepo mapDataRepo) => ScheduleRepoImpl(firestore, authenticator, localeState, mapDataRepo);

  @provide
  ScheduleViewModel scheduleViewModel(ScheduleRepo scheduleRepo, PlaceSelectionInteractor placeSelectionInteractor) => ScheduleViewModel(scheduleRepo, placeSelectionInteractor);

  @provide
  @singleton
  ConfigRepo configRepo(Firestore firestore, Authenticator authenticator, LocaleState localeState) => ConfigRepoImpl(firestore, authenticator, localeState);

  @provide
  MainViewModel mainViewModel(ConfigRepo configRepo, PermissionRepo permissionRepo, NotificationRepo notificationRepo, PlaceSelectionInteractor placeSelectionInteractor) =>
      MainViewModel(configRepo, permissionRepo, notificationRepo, placeSelectionInteractor);

  @provide
  @singleton
  CharityRepo charityRepo(Firestore firestore, Authenticator authenticator, LocaleState localeState) => CharityRepoImpl(firestore, authenticator, localeState);

  @provide
  CharityViewModel charityViewModel(CharityRepo charityRepo) => CharityViewModel(charityRepo);

  @provide
  @singleton
  TextRepo legalRepo(LocaleState localeState) => TextRepoImpl(localeState);

  @provide
  LegalViewModel legalViewModel(TextRepo textRepo) => LegalViewModel(textRepo);

  @provide
  FeedbackViewModel feedbackViewModel(TextRepo textRepo) => FeedbackViewModel(textRepo);

  @provide
  @singleton
  PermissionRepo permissionRepo() => PermissionRepoImpl();

  @provide
  @singleton
  NotificationRepo notificationRepo(FirebaseMessaging firebaseMessaging, Firestore firestore, Authenticator authenticator, FirebaseMessageParser firebaseMessageParser, LocaleState localeState) =>
      NotificationRepoImpl(firebaseMessaging, firestore, authenticator, firebaseMessageParser, localeState);

  @provide
  NotificationListViewModel notificationListViewModel(NotificationRepo notificationRepo) => NotificationListViewModel(notificationRepo);

  @provide
  @singleton
  EventInfoRepo eventInfoRepo(Authenticator authenticator, LocaleState localeState, Firestore firestore) => EventInfoRepoImpl(authenticator, firestore, localeState);

  @provide
  EventInfoViewModel eventInfoViewModel(EventInfoRepo eventInfoRepo) => EventInfoViewModel(eventInfoRepo);

  @provide
  @singleton
  FeedRepo feedRepo(Authenticator authenticator, Firestore firestore) => FeedRepoImpl(firestore, authenticator);

  @provide
  FeedViewModel feedViewModel(FeedRepo feedRepo) => FeedViewModel(feedRepo);

  @provide
  @singleton
  LocaleState localeState() => LocaleState();

  @provide
  FirebaseMessaging firebaseMessaging() => FirebaseMessaging();

  @provide
  FirebaseMessageParser firebaseMessageParser() {
    if (Platform.isIOS) {
      return IosFirebaseMessageParser();
    } else if (Platform.isAndroid) {
      return AndroidFirebaseMessageParser();
    }
    return null;
  }

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