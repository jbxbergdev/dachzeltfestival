import 'package:dachzeltfestival/model/schedule/schedule_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

abstract class ScheduleRepo {
  Stream<List<ScheduleItem>> observeSchedule();
}

class ScheduleRepoImpl extends ScheduleRepo {

  static const String _FIRESTORE_COLLECTION_SCHEDULE = "schedule";
  static const String _FIRESTORE_COLLECTION_VENUE = "venue";

  final Firestore _firestore;

  ScheduleRepoImpl(this._firestore);

  @override
  Stream<List<ScheduleItem>> observeSchedule() {
    return Observable.combineLatest2<QuerySnapshot, QuerySnapshot, List<ScheduleItem>>(
        _firestore.collection(_FIRESTORE_COLLECTION_SCHEDULE).snapshots(),
        _firestore.collection(_FIRESTORE_COLLECTION_VENUE).snapshots(),
        _mapSchedule);
  }

  List<ScheduleItem> _mapSchedule(QuerySnapshot scheduleQuerySnapshot, QuerySnapshot venueQuerySnapshot) {
    List<DocumentSnapshot> venueDocuments = venueQuerySnapshot.documents;
    return scheduleQuerySnapshot.documents.map((scheduleDocument) {
      String venueId = scheduleDocument.data['venue_id'];
      String venueName, venueColor;
      if (venueId != null && venueDocuments?.isNotEmpty == true) {
        DocumentSnapshot venueDocument = venueDocuments.firstWhere((documentSnapshot) => venueId == documentSnapshot.documentID, orElse: () => null);
        if (venueDocument != null) {
          venueName = venueDocument.data['name'];
          venueColor = venueDocument.data['color'];
        }
      }
      return ScheduleItem(
        (scheduleDocument.data['start'] as Timestamp).toDate(),
        (scheduleDocument.data['finish'] as Timestamp).toDate(),
        scheduleDocument.data['title'],
        scheduleDocument.data['abstract'],
        scheduleDocument.data['speaker'],
        venueName,
        venueColor,
      );
    }).toList()..sort((item1, item2) => item1.start.compareTo(item2.start));
  }

}