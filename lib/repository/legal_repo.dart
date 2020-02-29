import 'dart:ui';

import 'package:dachzeltfestival/i18n/locale_state.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

abstract class TextRepo {
  Stream<String> legalMarkdown();
  Stream<String> feedbackMarkdown();
}

class TextRepoImpl extends TextRepo {

  static const String legal = 'assets/text/legalmarkdown';
  static const String feedback = 'assets/text/feedbackmarkdown';

  final LocaleState _localeState;

  TextRepoImpl(this._localeState);

  @override
  Stream<String> legalMarkdown() => _loadString(legal);

  @override
  Stream<String> feedbackMarkdown() =>_loadString(feedback);

  Stream<String> _loadString(String filePath) {
    return _localeState.locale
        .flatMap((locale) => _loadLocalizedAssetFile(locale, filePath).asStream());
  }

  Future<String> _loadLocalizedAssetFile(Locale locale, String filePath) {
    return rootBundle.loadString("${filePath}_${locale.languageCode}")
        .catchError((_) => rootBundle.loadString(filePath));
  }


}