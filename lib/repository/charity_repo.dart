import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dachzeltfestival/i18n/locale_state.dart';
import 'package:dachzeltfestival/model/configuration/charity_config.dart';
import 'package:dachzeltfestival/repository/authenticator.dart';
import 'package:dachzeltfestival/repository/translatable_document.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

abstract class CharityRepo {
  Stream<CharityConfig> charityConfig;
}

@Singleton(as: CharityRepo)
class CharityRepoImpl extends CharityRepo {
  
  final FirebaseFirestore _firestore;
  final Authenticator _authenticator;
  final LocaleState _localeState;


  CharityRepoImpl(this._firestore, this._authenticator, this._localeState);


  @override
  Stream<CharityConfig> get charityConfig {
    Stream<CharityConfig> charityConfigFromFirestore = Rx.combineLatest2(
      _firestore.collection("configuration").doc("charity_config").snapshots(),
      _localeState.locale,
      _mapToCharityConfig
    );
    return _authenticator.authenticated.flatMap(
        (authenticated) => authenticated ? charityConfigFromFirestore : Stream.value(null)
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
