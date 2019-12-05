import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dachzeltfestival/i18n/locale_state.dart';
import 'package:dachzeltfestival/model/configuration/charity_config.dart';
import 'package:dachzeltfestival/repository/authenticator.dart';
import 'package:dachzeltfestival/repository/translatable_document.dart';
import 'package:rxdart/rxdart.dart';

abstract class CharityRepo {
  Observable<CharityConfig> charityConfig;
}

class CharityRepoImpl extends CharityRepo {
  
  final Firestore _firestore;
  final Authenticator _authenticator;
  final LocaleState _localeState;


  CharityRepoImpl(this._firestore, this._authenticator, this._localeState);


  @override
  Observable<CharityConfig> get charityConfig {
    Observable<CharityConfig> charityConfigFromFirestore = Observable.combineLatest2(
      _firestore.collection("configuration").document("charity_config").snapshots(),
      _localeState.localeSubject,
      _mapToCharityConfig
    );
    return _authenticator.authenticated.flatMap(
        (authenticated) => authenticated ? charityConfigFromFirestore : Observable.just(null)
    );
  }

  CharityConfig _mapToCharityConfig(DocumentSnapshot documentSnapshot, Locale locale) {
    TranslatableDocument translatableDocument = TranslatableDocument(documentSnapshot, locale);
    return CharityConfig(
      titleText: translatableDocument["title"],
      explanationText: translatableDocument["description"],
      buttonText: translatableDocument["button_text"],
      buttonLink: translatableDocument["button_url"]
    );
  }

}
