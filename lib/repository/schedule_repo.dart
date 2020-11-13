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

//  Stream<List<ScheduleItem>> _buildMockList() {
//    return Future<List<ScheduleItem>>.delayed(Duration(milliseconds: 500), () {
//      List<int> itemIndices = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20].toList();
//      List<int> dayIndices = [13,14,15,16,17].toList();
//
//      List<ScheduleItem> itemList = List();
//
//      dayIndices.forEach((day) {
//        int year = 2020;
//        int month = 5;
//        int hour = 1;
//        itemIndices.forEach((itemIndex) {
//          itemList.add(ScheduleItem(
//              DateTime(year, month, day, hour++),
//              DateTime(year, month, day, hour+2),
//              'Schedule Item $itemIndex',
//              'But I must explain to you how all this mistaken idea of denouncing pleasure and praising pain was born and I will give you a complete account of the system, and expound the actual teachings of the great explorer of the truth, the master-builder of human happiness. No one rejects, dislikes, or avoids pleasure itself, because it is pleasure, but because those who do not know how to pursue pleasure rationally encounter consequences that are extremely painful. Nor again is there anyone who loves or pursues or desires to obtain pain of itself, because it is pain, but because occasionally circumstances occur in which toil and pain can procure him some great pleasure. To take a trivial example, which of us ever undertakes laborious physical exercise, except to obtain some advantage from it? But who has any right to find fault with a man who chooses to enjoy a pleasure that has no annoying consequences, or one who avoids a pain that produces no resultant pleasure?',
//              'Laberklaus',
//              'DZF20',
//              'dzf20',
//              '#ff0000'
//          ));
//        });
//      });
//
//      return itemList;
//    }).asStream();
//  }

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