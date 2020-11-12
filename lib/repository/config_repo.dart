import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dachzeltfestival/i18n/locale_state.dart';
import 'package:dachzeltfestival/model/configuration/app_config.dart';
import 'package:dachzeltfestival/repository/authenticator.dart';
import 'package:dachzeltfestival/repository/translatable_document.dart';
import 'package:package_info/package_info.dart';
import 'package:rxdart/rxdart.dart';

abstract class ConfigRepo {
  Stream<AppConfig> appConfig;
  // ignore: close_sinks
  Sink<Locale> localeSink;
}

class ConfigRepoImpl extends ConfigRepo {

  final FirebaseFirestore _firestore;
  final Authenticator _authenticator;
  final LocaleState _localeState;

  ConfigRepoImpl(this._firestore, this._authenticator, this._localeState);

  @override
  Stream<AppConfig> get appConfig {
    Stream<AppConfig> appConfigFromFirestore = Rx.combineLatest3(
        _firestore.collection("configuration").doc("app_config").snapshots(),
        PackageInfo.fromPlatform().asStream(),
        _localeState.locale,
        _mapConfig
    );
    return _authenticator.authenticated.flatMap(
        (authenticated) => authenticated ? appConfigFromFirestore : Stream.value(null)
    );
  }

  @override
  // ignore: close_sinks
  Sink<Locale> get localeSink => _localeState.sink;

  AppConfig _mapConfig(DocumentSnapshot documentSnapshot, PackageInfo packageInfo, Locale locale) {
    int appVersion = int.parse(packageInfo.buildNumber);
    bool versionSupported = appVersion >= documentSnapshot["min_version"];
    String deprecationInfo = TranslatableDocument(documentSnapshot, locale)["deprecation_info"];
    return AppConfig(versionSupported, deprecationInfo);
  }
}