import 'dart:ui';

import 'package:rxdart/rxdart.dart';

class LocaleState {
  // ignore: close_sinks
  final BehaviorSubject<Locale> localeSubject = BehaviorSubject.seeded(null);
}