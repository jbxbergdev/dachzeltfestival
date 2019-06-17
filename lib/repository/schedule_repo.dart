import 'package:dachzeltfestival/model/schedule/schedule_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ScheduleRepo {
  Stream<List<ScheduleItem>> observeSchedule();
}

class ScheduleRepoImpl extends ScheduleRepo {

  static const String _FIRESTORE_COLLECTION_NAME = "schedule";

  final Firestore _firestore;

  ScheduleRepoImpl(this._firestore);

  @override
  Stream<List<ScheduleItem>> observeSchedule() {
    return _firestore.collection(_FIRESTORE_COLLECTION_NAME)
        .snapshots()
        .map((snapshot) => snapshot.documents
          .map((documentSnapshot) {
            return ScheduleItem(
                (documentSnapshot.data['start'] as Timestamp).toDate(),
                (documentSnapshot.data['finish'] as Timestamp).toDate(),
                documentSnapshot.data['title'],
                documentSnapshot.data['abstract'],
                documentSnapshot.data['speaker'],
                documentSnapshot.data['venue']
            );
          }
          ).toList()..sort((itemA, itemB) => itemA.start.compareTo(itemB.start))
    );
  }

}