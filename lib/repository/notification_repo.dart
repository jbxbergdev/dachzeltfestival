import 'dart:core';
import 'dart:io';
import 'dart:ui';

import 'package:dachzeltfestival/i18n/locale_state.dart';
import 'package:dachzeltfestival/i18n/translations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:dachzeltfestival/model/notification/notification.dart' as notification;

abstract class NotificationRepo {
  /// Must only have one subscription at a time!
  Observable<notification.Notification> notifications();
}

class NotificationRepoImpl extends NotificationRepo {

  final FirebaseMessaging _firebaseMessaging;
  final LocaleState _localeState;

  NotificationRepoImpl(this._firebaseMessaging, this._localeState);

  /// This must only have one subscription!
  @override
  Observable<notification.Notification> notifications() {
    _firebaseMessaging.requestNotificationPermissions();
    // ignore: close_sinks
    BehaviorSubject<notification.Notification> notificationSubject = BehaviorSubject.seeded(null);
    _firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> message) async {
        notificationSubject.add(_parseNotification(message));
      },
      onMessage: (Map<String, dynamic> message) async {
        notificationSubject.add(_parseNotification(message));
      },
      onResume: (Map<String, dynamic> message) async {
        notificationSubject.add(_parseNotification(message));
      },
    );

    // Set up language-based topic subscription
    List<String> supportedLanguages = Translations.supportedLanguages;
    _localeState.localeSubject.listen((locale) {
      // on a new locale, first unsubscribe from current language topic (i.e. unsubscribe from all topics)
      supportedLanguages.forEach((langCode) => _firebaseMessaging.unsubscribeFromTopic(langCode));

      // if the locale's language is supported, subscribe to its topic, otherwise subscribe to the default language
      if (supportedLanguages.contains(locale.languageCode)) {
        _firebaseMessaging.subscribeToTopic(locale.languageCode);
      } else {
        _firebaseMessaging.subscribeToTopic(supportedLanguages[0]);
      }
    });
    return notificationSubject.where((notification) => notification != null);
  }

  notification.Notification _parseNotification(Map<String, dynamic> fcMessage) {
    return notification.Notification(
      fcMessage['notification']['title'],
      fcMessage['notification']['body'],
    );
  }

}
