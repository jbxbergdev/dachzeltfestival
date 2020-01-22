import 'dart:collection';
import 'dart:ui';

import 'package:dachzeltfestival/i18n/locale_state.dart';
import 'package:dachzeltfestival/model/schedule/schedule_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dachzeltfestival/repository/authenticator.dart';
import 'package:dachzeltfestival/repository/mapdata_repo.dart';
import 'package:dachzeltfestival/repository/translatable_document.dart';
import 'package:rxdart/rxdart.dart';
import 'package:dachzeltfestival/model/geojson/feature.dart';


abstract class ScheduleRepo {
  Observable<List<ScheduleItem>> observeSchedule();
}

class ScheduleRepoImpl extends ScheduleRepo {

  static const String _FIRESTORE_COLLECTION_SCHEDULE = "schedule";

  final Firestore _firestore;
  final Authenticator _authenticator;
  final LocaleState _localeState;
  final MapDataRepo _mapDataRepo;

  ScheduleRepoImpl(this._firestore, this._authenticator, this._localeState, this._mapDataRepo);

  @override
  Observable<List<ScheduleItem>> observeSchedule() {
    Observable<List<ScheduleItem>> scheduleFromFirestore = Observable.combineLatest3<QuerySnapshot, Map<String, Feature>, Locale, List<ScheduleItem>>(
        _firestore.collection(_FIRESTORE_COLLECTION_SCHEDULE).snapshots(),
        _mapDataRepo.mapFeatures().map((featureCollection) =>
            // use a HashMap for performance reasons
            HashMap.fromIterable(featureCollection.features, key: (feature) => (feature as Feature).properties.placeId, value: (feature) => feature as Feature)),
        _localeState.localeSubject.distinct(),
        _mapSchedule);

    return _authenticator.authenticated.flatMap(
            (authenticated) => authenticated ? scheduleFromFirestore : Observable.just(List<ScheduleItem>()));

  }

  List<ScheduleItem> _mapSchedule(QuerySnapshot scheduleQuerySnapshot, Map<String, Feature> venues, Locale locale) {
    return scheduleQuerySnapshot.documents.map((scheduleDocument) {
      TranslatableDocument translatableDocument = TranslatableDocument(scheduleDocument, locale);
      String venueId = translatableDocument['venue_id'];
      String venueName, venueColor;
      Feature feature = venues[venueId];
      if (feature != null) {
        venueName = feature.properties.name;
        venueColor = feature.properties.fill;
      }
      return ScheduleItem(
        (translatableDocument['start'] as Timestamp).toDate(),
        (translatableDocument['finish'] as Timestamp).toDate(),
        translatableDocument['title'],
        translatableDocument['abstract'],
        translatableDocument['speaker'],
        venueName,
        venueId,
        venueColor,
      );
    }).toList()..sort((item1, item2) => item1.start.compareTo(item2.start));
  }

}