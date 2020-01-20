
import 'dart:ui';

import 'package:dachzeltfestival/model/configuration/app_config.dart';
import 'package:dachzeltfestival/model/notification/notification.dart' as notification;
import 'package:dachzeltfestival/repository/config_repo.dart';
import 'package:dachzeltfestival/repository/notification_repo.dart';
import 'package:dachzeltfestival/repository/permission_repo.dart';
import 'package:dachzeltfestival/view/place_selection_interactor.dart';
import 'package:inject/inject.dart';
import 'package:rxdart/rxdart.dart';

@provide
class MainViewModel {
  final ConfigRepo _configRepo;
  final PermissionRepo _permissionRepo;
  final NotificationRepo _notificationRepo;
  final PlaceSelectionInteractor _placeSelectionInteractor;

  MainViewModel(this._configRepo, this._permissionRepo, this._notificationRepo, this._placeSelectionInteractor);

  BehaviorSubject<Locale> get localeSubject => _configRepo.localeSubject;

  Observable<AppConfig> get appConfig => _configRepo.appConfig;

  Observable<notification.Notification> get notifications => _notificationRepo.newNotifications();

  PlaceSelectionInteractor get placeSelectionInteractor => _placeSelectionInteractor;

  void requestLocationPermission() {
    _permissionRepo.requestLocationPermission();
  }
}

