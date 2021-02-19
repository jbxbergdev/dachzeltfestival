import 'dart:collection';
import 'dart:ui';

import 'package:dachzeltfestival/i18n/locale_state.dart';
import 'package:dachzeltfestival/model/schedule/schedule_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dachzeltfestival/repository/authenticator.dart';
import 'package:dachzeltfestival/repository/mapdata_repo.dart';
import 'package:dachzeltfestival/repository/translatable_document.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:dachzeltfestival/model/geojson/feature.dart';


abstract class ScheduleRepo {
  Stream<List<ScheduleItem>> observeSchedule();
}

@Singleton(as: ScheduleRepo)
class ScheduleRepoImpl extends ScheduleRepo {

  static const String _FIRESTORE_COLLECTION_SCHEDULE = "schedule";

  final FirebaseFirestore _firestore;
  final Authenticator _authenticator;
  final LocaleState _localeState;
  final MapDataRepo _mapDataRepo;

  ScheduleRepoImpl(this._firestore, this._authenticator, this._localeState, this._mapDataRepo);

  @override
  Stream<List<ScheduleItem>> observeSchedule() {
//    return Observable(_buildMockList());
    Stream<List<ScheduleItem>> scheduleFromFirestore = Rx.combineLatest3<QuerySnapshot, Map<String, Feature>, Locale, List<ScheduleItem>>(
        _firestore.collection(_FIRESTORE_COLLECTION_SCHEDULE).orderBy('start', descending: false).snapshots(),
        _mapDataRepo.mapFeatures().map((featureCollection) =>
            // use a HashMap for performance reasons
            HashMap.fromIterable(featureCollection.features, key: (feature) => (feature as Feature).properties.placeId, value: (feature) => feature as Feature)),
        _localeState.locale,
        _mapSchedule);

    return _authenticator.authenticated.flatMap(
            (authenticated) => authenticated ? scheduleFromFirestore : Stream.value(List<ScheduleItem>()));
  }

  List<ScheduleItem> _mapSchedule(QuerySnapshot scheduleQuerySnapshot, Map<String, Feature> venues, Locale locale) {
    return scheduleQuerySnapshot.docs.map((scheduleDocument) {
      TranslatableDocument translatableDocument = TranslatableDocument(scheduleDocument, locale);
      String venueId = translatableDocument['venue_id'];
      String venueName, venueColor;
      Feature feature = venues[venueId];
      if (feature != null) {
        venueName = feature.properties.name;
        venueColor = feature.properties.fill;
      }
      return ScheduleItem(
        start: (translatableDocument['start'] as Timestamp).toDate(),
        finish: (translatableDocument['finish'] as Timestamp).toDate(),
        title: translatableDocument['title'],
        abstract: translatableDocument['abstract'],
        speaker: translatableDocument['speaker'],
        venue: venueName,
        placeId: venueId,
        color: venueColor,
        url: translatableDocument['url'],
        linkText: translatableDocument['link_text'],
      );
    }).toList()..sort((item1, item2) => item1.start.compareTo(item2.start));
  }

}