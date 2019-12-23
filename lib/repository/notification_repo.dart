import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dachzeltfestival/i18n/locale_state.dart';
import 'package:dachzeltfestival/i18n/translations.dart';
import 'package:dachzeltfestival/repository/firebase_message_parser.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:dachzeltfestival/model/notification/notification.dart' as notification;

abstract class NotificationRepo {
  /// Must only have one subscription at a time!
  Observable<notification.Notification> newNotifications();

  Observable<List<notification.Notification>> allNotifications();
}

class NotificationRepoImpl extends NotificationRepo {

  final FirebaseMessaging _firebaseMessaging;
  final Firestore _firestore;
  final LocaleState _localeState;
  final FirebaseMessageParser _firebaseMessageParser;
  final PublishSubject<String> _fcmMessageSubject = PublishSubject();
  Observable<String> _newNotificationIds;

  NotificationRepoImpl(this._firebaseMessaging, this._firestore, this._firebaseMessageParser, this._localeState) {
    _newNotificationIds = _fcmMessageSubject.where((messageId) => messageId != null).distinct();
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> message) async {
        print('##### onLaunch');
        _fcmMessageSubject.add(_firebaseMessageParser.parseDocumentId(message));
      },
      onMessage: (Map<String, dynamic> message) async {
        print('##### onMessage');
        _fcmMessageSubject.add(_firebaseMessageParser.parseDocumentId(message));
      },
      onResume: (Map<String, dynamic> message) async {
        print('##### onResume');
        _fcmMessageSubject.add(_firebaseMessageParser.parseDocumentId(message));
      },
    );
    List<String> supportedLanguages = Translations.supportedLanguages;
    _localeState.localeSubject.where((locale) => locale != null).listen((locale) {
      // on a new locale, first unsubscribe from current language topic (i.e. unsubscribe from all topics)
      supportedLanguages.forEach((langCode) => _firebaseMessaging.unsubscribeFromTopic(langCode));

      // if the locale's language is supported, subscribe to its topic, otherwise subscribe to the default language
      if (supportedLanguages.contains(locale.languageCode)) {
        _firebaseMessaging.subscribeToTopic(locale.languageCode);
      } else {
        _firebaseMessaging.subscribeToTopic(supportedLanguages[0]);
      }
    });
  }

  /// This must only have one subscription!
  @override
  Observable<notification.Notification> newNotifications() {
    // Set up language-based topic subscription
    return _newNotificationIds.flatMap((documentId) => _firestore.document('notifications/$documentId').snapshots()
        .map((documentSnapshot) => documentSnapshot.asNotification));
  }

  @override
  Observable<List<notification.Notification>> allNotifications() {
    return _localeState.localeSubject.flatMap((locale) =>
        Observable(_firestore.collection('notifications')
            .where('language', isEqualTo: locale.supportedOrDefaultLangCode)
            .orderBy('timestamp', descending: true)
            .snapshots())
        .map((querySnapshot) => querySnapshot.documents.map((documentSnapshot) => documentSnapshot.asNotification).toList()).doOnError((error) => print(error)));
  }
}

extension _NotificationParser on DocumentSnapshot {
  notification.Notification get asNotification =>
      notification.Notification(this['title'], this['message'], this['url'], (this['timestamp'] as Timestamp).toDate());
}

