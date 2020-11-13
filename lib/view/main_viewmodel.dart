
import 'dart:ui';

import 'package:dachzeltfestival/model/configuration/app_config.dart';
import 'package:dachzeltfestival/model/notification/notification.dart' as notification;
import 'package:dachzeltfestival/repository/config_repo.dart';
import 'package:dachzeltfestival/repository/notification_repo.dart';
import 'package:dachzeltfestival/repository/permission_repo.dart';
import 'package:dachzeltfestival/view/place_selection_interactor.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

@injectable
class MainViewModel {
  final ConfigRepo _configRepo;
  final PermissionRepo _permissionRepo;
  final NotificationRepo _notificationRepo;
  final PlaceSelectionInteractor _placeSelectionInteractor;
  final BehaviorSubject<AppConfig> _appConfigSubject = BehaviorSubject();

  MainViewModel(this._configRepo, this._permissionRepo, this._notificationRepo, this._placeSelectionInteractor) {
    _configRepo.appConfig.listen((appConfig) => _appConfigSubject.add(appConfig));
  }

  Sink<Locale> get localeSink => _configRepo.localeSink;

  Stream<AppConfig> get appConfig => _appConfigSubject;

  Stream<notification.Notification> get notifications => _notificationRepo.newNotifications();

  PlaceSelectionInteractor get placeSelectionInteractor => _placeSelectionInteractor;

  void requestLocationPermission() {
    _permissionRepo.requestLocationPermission();
  }
}

