
import 'dart:ui';

import 'package:dachzeltfestival/model/configuration/app_config.dart';
import 'package:dachzeltfestival/repository/config_repo.dart';
import 'package:inject/inject.dart';
import 'package:rxdart/rxdart.dart';

@provide
class MainViewModel {
  final ConfigRepo _configRepo;

  MainViewModel(this._configRepo);

  BehaviorSubject<Locale> get localeSubject {
    return _configRepo.localeSubject;
  }

  Observable<AppConfig> get appConfig {
    return _configRepo.appConfig;
  }
}