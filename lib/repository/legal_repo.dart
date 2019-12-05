import 'dart:ui';

import 'package:dachzeltfestival/i18n/locale_state.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

abstract class LegalRepo {
  Observable<String> legalMarkdown();
}

class LegalRepoImpl extends LegalRepo {

  static const String translatableFilePath = "assets/text/legalmarkdown";

  final LocaleState _localeState;

  LegalRepoImpl(this._localeState);

  @override
  Observable<String> legalMarkdown() {
    return _localeState.localeSubject.where((locale) => locale != null)
        .flatMap((locale) => _loadLocalizedAssetFile(locale).asStream());
  }

  Future<String> _loadLocalizedAssetFile(Locale locale) {
    return rootBundle.loadString("${translatableFilePath}_${locale.languageCode}")
        .catchError((_) => rootBundle.loadString(translatableFilePath));
  }


}