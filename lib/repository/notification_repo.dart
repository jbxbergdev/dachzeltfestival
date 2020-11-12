import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dachzeltfestival/i18n/locale_state.dart';
import 'package:dachzeltfestival/i18n/translations.dart';
import 'package:dachzeltfestival/repository/authenticator.dart';
import 'package:dachzeltfestival/repository/firebase_message_parser.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:dachzeltfestival/model/notification/notification.dart' as notification;

abstract class NotificationRepo {
  /// Must only have one subscription at a time!
  Stream<notification.Notification> newNotifications();

  Stream<List<notification.Notification>> allNotifications();
}

class NotificationRepoImpl extends NotificationRepo {

  final FirebaseMessaging _firebaseMessaging;
  final FirebaseFirestore _firestore;
  final Authenticator _authenticator;
  final LocaleState _localeState;
  final FirebaseMessageParser _firebaseMessageParser;
  final PublishSubject<String> _fcmMessageSubject = PublishSubject();
  final BehaviorSubject<bool> _languageSubscriptionActive = BehaviorSubject.seeded(false);
  Stream<String> _newNotificationIds;

  NotificationRepoImpl(this._firebaseMessaging, this._firestore, this._authenticator, this._firebaseMessageParser, this._localeState) {
    _newNotificationIds = _fcmMessageSubject.where((messageId) => messageId != null).distinct();
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> message) async {
        _fcmMessageSubject.add(_firebaseMessageParser.parseDocumentId(message));
      },
      onMessage: (Map<String, dynamic> message) async {
        _fcmMessageSubject.add(_firebaseMessageParser.parseDocumentId(message));
      },
      onResume: (Map<String, dynamic> message) async {
        _fcmMessageSubject.add(_firebaseMessageParser.parseDocumentId(message));
      },
    );

    List<String> supportedLanguages = Translations.supportedLanguages;
    _localeState.locale.listen((locale) {
      _languageSubscriptionActive.add(false);
      // on a new locale, first unsubscribe from current language topic (i.e. unsubscribe from all topics)
      supportedLanguages.forEach((langCode) => _firebaseMessaging.unsubscribeFromTopic(langCode));

      // if the locale's language is supported, subscribe to its topic, otherwise subscribe to the default language
      if (supportedLanguages.contains(locale.languageCode)) {
        _firebaseMessaging.subscribeToTopic(locale.languageCode).whenComplete(() => _languageSubscriptionActive.add(true));
      } else {
        _firebaseMessaging.subscribeToTopic(supportedLanguages[0]).whenComplete(() => _languageSubscriptionActive.add(true));
      }
    });
  }

  /// This must only have one subscription!
  @override
  Stream<notification.Notification> newNotifications() {
    // Set up language-based topic subscription
    Stream<notification.Notification> notificationStream = _newNotificationIds.flatMap((documentId) => _firestore.doc('notifications/$documentId').snapshots().first.asStream()
        .map((documentSnapshot) => documentSnapshot.asNotification));
    return _authenticator.authenticated.where((authenticated) => authenticated).flatMap((_) => notificationStream);
  }

  @override
  Stream<List<notification.Notification>> allNotifications() {
    Stream<List<notification.Notification>> notificationStream = _localeState.locale
        .flatMap((locale) =>
        _firestore.collection('notifications')
            .where('language', isEqualTo: locale.supportedOrDefaultLangCode)
            .orderBy('timestamp', descending: true)
            .snapshots()
            .map((querySnapshot) => querySnapshot.docs.map((documentSnapshot) => documentSnapshot.asNotification).toList()).doOnError((error) => print(error)));
    return _authenticator.authenticated.where((authenticated) => authenticated).flatMap((_) => notificationStream);
  }
}

extension _NotificationParser on DocumentSnapshot {
  notification.Notification get asNotification =>
      notification.Notification(data()['title'], data()['message'], data()['url'], (data()['timestamp'] as Timestamp).toDate(), data()['persistent'] ?? false);
}

