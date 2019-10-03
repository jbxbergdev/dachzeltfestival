import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dachzeltfestival/model/configuration/app_config.dart';
import 'package:dachzeltfestival/repository/translatable_document.dart';
import 'package:package_info/package_info.dart';
import 'package:rxdart/rxdart.dart';

abstract class ConfigRepo {
  Observable<AppConfig> appConfig;
  // ignore: close_sinks
  BehaviorSubject<Locale> localeSubject;
}

class ConfigRepoImpl extends ConfigRepo {

  final Firestore _firestore;

  ConfigRepoImpl(this._firestore);

  @override
  Observable<AppConfig> get appConfig {
    return Observable.combineLatest3(
        _firestore.collection("configuration").document("app_config").snapshots(),
        PackageInfo.fromPlatform().asStream(),
        localeSubject,
        _mapConfig
    );
  }

  @override
  // ignore: close_sinks
  final BehaviorSubject<Locale> localeSubject = BehaviorSubject.seeded(null);

  AppConfig _mapConfig(DocumentSnapshot documentSnapshot, PackageInfo packageInfo, Locale locale) {
    int appVersion = int.parse(packageInfo.buildNumber);
    bool versionSupported = appVersion >= documentSnapshot["min_version"];
    print('##### appVersion: $appVersion, minVersion: ${documentSnapshot["min_version"]}');
    String deprecationInfo = TranslatableDocument(documentSnapshot, locale)["deprecation_info"];
    return AppConfig(versionSupported, deprecationInfo);
  }
}