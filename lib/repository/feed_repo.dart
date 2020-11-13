import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dachzeltfestival/repository/authenticator.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

abstract class FeedRepo {
  Stream<String> feedHtml;
}

@Singleton(as: FeedRepo)
class FeedRepoImpl extends FeedRepo {
  final FirebaseFirestore _firestore;
  final Authenticator _authenticator;

  FeedRepoImpl(this._firestore, this._authenticator);

  @override
  Stream<String> get feedHtml {
    Stream<String> htmlFromFirestore = _firestore.collection('configuration').doc('feed_config')
        .snapshots()
        .map((documentSnapshot) => documentSnapshot.data()['html'] as String)
        .where((html) => html != null);
    return _authenticator.authenticated.where((authenticated) => authenticated)
        .flatMap((_) => htmlFromFirestore);
  }
}