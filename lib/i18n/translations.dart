import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

enum AppString {
  appName,
  navItemSchedule,
  navItemMap,
  navItemDonate,
  navItemMore,
  scheduleUntil,
  dismiss,
  notificationDialogOpenLink,
  notificationListTitle,
  eventInfo,
  legal,
  feedback,
  today,
  yesterday,
  loading,
  vendors,
  advertisement,
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
    AppString.navItemMore: {
      de: "Mehr",
      en: "More"
    },
    AppString.scheduleUntil: {
      de: "bis",
      en: "until"
    },
    AppString.dismiss: {
      de: "SCHLIESSEN",
      en: "DISMISS"
    },
    AppString.notificationDialogOpenLink: {
      de: "LINK ÖFFNEN",
      en: "OPEN LINK"
    },
    AppString.notificationListTitle: {
      de: "News",
      en: "News"
    },
    AppString.eventInfo: {
      de: "Event Infos",
      en: "Event Information"
    },
    AppString.legal: {
      de: "Über die App, Impressum",
      en: "About, Legal"
    },
    AppString.feedback: {
      de: "Feedback",
      en: "Feedback"
    },
    AppString.today: {
      de: "heute",
      en: "today"
    },
    AppString.yesterday: {
      de: "gestern",
      en: "yesterday"
    },
    AppString.loading: {
      de: "Lade...",
      en: "Loading..."
    },
    AppString.vendors: {
      de: "Händler",
      en: "Vendors"
    },
    AppString.advertisement: {
      de: "WERBUNG",
      en: "ADVERTISEMENT"
    },
  };

  dynamic operator[](AppString appString) => _stringMap[appString][_locale.languageCode];

  static Translations of(BuildContext context) => Localizations.of<Translations>(context, Translations);
}

extension ContextTranslations on BuildContext {
  Translations get translations => Translations.of(this);
}

extension LocaleExt on Locale {
  String get supportedOrDefaultLangCode =>
      Translations.supportedLanguages.contains(this.languageCode) ? this.languageCode : Translations.supportedLanguages[0];
}

class TranslationsDelegate extends LocalizationsDelegate<Translations> {

  @override
  bool isSupported(Locale locale) => Translations.supportedLanguages.contains(locale.languageCode);

  @override
  Future<Translations> load(Locale locale) => SynchronousFuture<Translations>(Translations(locale));

  @override
  bool shouldReload(LocalizationsDelegate<Translations> old) => false;

}
