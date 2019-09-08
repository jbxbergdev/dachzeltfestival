import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

enum AppString {
  appName,
  navItemSchedule,
  navItemMap,
  navItemDonate
}

class Translations {

  final Locale _locale;

  Translations(this._locale);

  static const String de = "de";
  static const String en = "en";
  static const List<String> supportedLanguages = [en, de]; // first one is used as fallback

  final Map<AppString, Map<String, String>> _stringMap = {
    AppString.appName: {
      de: "Dachzeltfestival",
      en: "Dachzeltfestival"
    },
    AppString.navItemSchedule: {
      de: "Programm",
      en: "Schedule"
    },
    AppString.navItemMap: {
      de: "Karte",
      en: "Map"
    },
    AppString.navItemDonate: {
      de: "Danke",
      en: "Danke"
    }
  };

  String get(AppString appString) => _stringMap[appString][_locale.languageCode];

  static Translations of(BuildContext context) => Localizations.of<Translations>(context, Translations);
}

class TranslationsDelegate extends LocalizationsDelegate<Translations> {

  @override
  bool isSupported(Locale locale) => Translations.supportedLanguages.contains(locale.languageCode);

  @override
  Future<Translations> load(Locale locale) => SynchronousFuture<Translations>(Translations(locale));

  @override
  bool shouldReload(LocalizationsDelegate<Translations> old) => false;

}
