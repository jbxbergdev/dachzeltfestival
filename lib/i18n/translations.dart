import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

enum AppString {
  appName,
  navItemSchedule,
  navItemMap,
  navItemDonate,
  navItemInfo,
  scheduleUntil,
  ok,
  notificationDialogOpenLink,
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
      de: "Show Love",
      en: "Show Love"
    },
    AppString.navItemInfo: {
      de: "Info",
      en: "Info"
    },
    AppString.scheduleUntil: {
      de: "bis",
      en: "until"
    },
    AppString.ok: {
      de: "OK",
      en: "OK,"
    },
    AppString.notificationDialogOpenLink: {
      de: "Link öffnen",
      en: "Open link"
    }
  };

  dynamic operator[](AppString appString) => _stringMap[appString][_locale.languageCode];

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
