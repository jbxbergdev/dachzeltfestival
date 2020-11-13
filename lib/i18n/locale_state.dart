import 'dart:ui';

import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

@singleton
class LocaleState {
  // ignore: close_sinks
  final BehaviorSubject<Locale> _localeSubject = BehaviorSubject.seeded(null);

  Stream<Locale> get locale => _localeSubject
      .where((locale) => locale != null)
      .distinct((left, right) => left.languageCode == right.languageCode);

  Sink<Locale> get sink => _localeSubject;
}