import 'dart:ui';

import 'package:dachzeltfestival/model/schedule/schedule_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dachzeltfestival/repository/translatable_document.dart';
import 'package:rxdart/rxdart.dart';


abstract class ScheduleRepo {
  Stream<List<ScheduleItem>> observeSchedule();
  // ignore: close_sinks
  BehaviorSubject localeSubject;
}

class ScheduleRepoImpl extends ScheduleRepo {

  static const String _FIRESTORE_COLLECTION_SCHEDULE = "schedule";
  static const String _FIRESTORE_COLLECTION_VENUE = "venue";

  final Firestore _firestore;

  @override
  final BehaviorSubject<Locale> localeSubject = BehaviorSubject.seeded(null);

  ScheduleRepoImpl(this._firestore);

  @override
  Stream<List<ScheduleItem>> observeSchedule() {
    return Observable.combineLatest3<QuerySnapshot, QuerySnapshot, Locale, List<ScheduleItem>>(
        _firestore.collection(_FIRESTORE_COLLECTION_SCHEDULE).snapshots(),
        _firestore.collection(_FIRESTORE_COLLECTION_VENUE).snapshots(),
        localeSubject.distinct(),
        _mapSchedule);
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