import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dachzeltfestival/model/configuration/charity_config.dart';
import 'package:dachzeltfestival/repository/authenticator.dart';
import 'package:dachzeltfestival/repository/translatable_document.dart';
import 'package:rxdart/rxdart.dart';

abstract class CharityRepo {
  // ignore: close_sinks
  BehaviorSubject<Locale> localeSubject;
  Observable<CharityConfig> charityConfig;
}

class CharityRepoImpl extends CharityRepo {
  
  final Firestore _firestore;
  final Authenticator _authenticator;
  
  CharityRepoImpl(this._firestore, this._authenticator);
  
  @override
  // ignore: close_sinks
  BehaviorSubject<Locale> localeSubject = BehaviorSubject();
  
  @override
  Observable<CharityConfig> get charityConfig {
    Observable<CharityConfig> charityConfigFromFirestore = Observable.combineLatest2(
      _firestore.collection("configuration").document("charity_config").snapshots(),
      localeSubject,
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
