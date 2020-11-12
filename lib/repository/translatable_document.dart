import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';

class TranslatableDocument {

  final DocumentSnapshot _documentSnapshot;
  final Locale _locale;

  TranslatableDocument(this._documentSnapshot, this._locale);

  dynamic operator[](String key) {
    String localized = _documentSnapshot.data()["${key}_${_locale.languageCode}"];
    if (localized?.isEmpty == true) { localized = null; }
    return localized ?? _documentSnapshot.data()[key];
  }
}

