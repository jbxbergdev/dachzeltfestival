import 'dart:ui';

import 'package:dachzeltfestival/i18n/locale_state.dart';
import 'package:dachzeltfestival/model/schedule/schedule_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dachzeltfestival/repository/authenticator.dart';
import 'package:dachzeltfestival/repository/translatable_document.dart';
import 'package:rxdart/rxdart.dart';


abstract class ScheduleRepo {
  Observable<List<ScheduleItem>> observeSchedule();
}

class ScheduleRepoImpl extends ScheduleRepo {

  static const String _FIRESTORE_COLLECTION_SCHEDULE = "schedule";
  static const String _FIRESTORE_COLLECTION_VENUE = "venue";

  final Firestore _firestore;
  final Authenticator _authenticator;
  final LocaleState _localeState;

  ScheduleRepoImpl(this._firestore, this._authenticator, this._localeState);

  @override
  Observable<List<ScheduleItem>> observeSchedule() {
    Observable<List<ScheduleItem>> scheduleFromFirestore = Observable.combineLatest3<QuerySnapshot, QuerySnapshot, Locale, List<ScheduleItem>>(
        _firestore.collection(_FIRESTORE_COLLECTION_SCHEDULE).snapshots(),
        _firestore.collection(_FIRESTORE_COLLECTION_VENUE).snapshots(),
        _localeState.localeSubject.distinct(),
        _mapSchedule);

    return _authenticator.authenticated.flatMap(
            (authenticated) => authenticated ? scheduleFromFirestore : Observable.just(List<ScheduleItem>()));

  }

  List<ScheduleItem> _mapSchedule(QuerySnapshot scheduleQuerySnapshot, QuerySnapshot venueQuerySnapshot, Locale locale) {
    List<DocumentSnapshot> venueDocuments = venueQuerySnapshot.documents;
    return scheduleQuerySnapshot.documents.map((scheduleDocument) {
      TranslatableDocument translatableDocument = TranslatableDocument(scheduleDocument, locale);
      String venueId = translatableDocument['venue_id'];
      String venueName, venueColor;
      if (venueId != null && venueDocuments?.isNotEmpty == true) {
        DocumentSnapshot venueDocument = venueDocuments.firstWhere((documentSnapshot) => venueId == documentSnapshot.documentID, orElse: () => null);
        if (venueDocument != null) {
          venueName = translatableDocument['name'];
          venueColor = translatableDocument['color'];
        }
      }
      return ScheduleItem(
        (translatableDocument['start'] as Timestamp).toDate(),
        (translatableDocument['finish'] as Timestamp).toDate(),
        translatableDocument['title'],
        translatableDocument['abstract'],
        translatableDocument['speaker'],
        venueName,
        venueColor,
      );
    }).toList()..sort((item1, item2) => item1.start.compareTo(item2.start));
  }

}