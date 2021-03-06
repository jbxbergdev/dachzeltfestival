import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dachzeltfestival/i18n/locale_state.dart';
import 'package:dachzeltfestival/repository/authenticator.dart';
import 'package:dachzeltfestival/repository/translatable_document.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

abstract class EventInfoRepo {
  Stream<String> eventInfoMarkup;
}

@Singleton(as: EventInfoRepo)
class EventInfoRepoImpl extends EventInfoRepo {

  final Authenticator _authenticator;
  final LocaleState _localeState;
  final FirebaseFirestore _firestore;

  EventInfoRepoImpl(this._authenticator, this._firestore, this._localeState);

  @override
  Stream<String> get eventInfoMarkup {
    Stream<String> markdownFromFirestore = Rx.combineLatest2(
        _firestore.collection('configuration').doc('event_info_config').snapshots(),
        _localeState.locale,
        _mapMarkdown
    );
    return _authenticator.authenticated.flatMap(
            (authenticated) => authenticated ? markdownFromFirestore : Stream.value(null)
    );
  }

  String _mapMarkdown(DocumentSnapshot documentSnapshot, Locale locale) {
    TranslatableDocument translatableDocument = TranslatableDocument(documentSnapshot, locale);
    return translatableDocument['markdown'];
  }
}