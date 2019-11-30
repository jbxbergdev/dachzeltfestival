import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

abstract class LegalRepo {
  // ignore: close_sinks
  BehaviorSubject<Locale> localeSubject;
  Observable<String> legalMarkdown();
}

class LegalRepoImpl extends LegalRepo {

  static const String translatableFilePath = "assets/text/legalmarkdown";

  @override
  BehaviorSubject<Locale> localeSubject = BehaviorSubject.seeded(null);

  @override
  Observable<String> legalMarkdown() {
    return localeSubject.where((locale) => locale != null)
        .flatMap((locale) => _loadLocalizedAssetFile(locale).asStream());
  }

  Future<String> _loadLocalizedAssetFile(Locale locale) {
    return rootBundle.loadString("${translatableFilePath}_${locale.languageCode}")
        .catchError((_) => rootBundle.loadString(translatableFilePath));
  }


}