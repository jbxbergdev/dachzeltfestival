
import 'package:injectable/injectable.dart';

abstract class FirebaseMessageParser {
  String parseDocumentId(Map<String, dynamic> message);
}

class AndroidFirebaseMessageParser extends FirebaseMessageParser {
  @override
  String parseDocumentId(Map<String, dynamic> message) {
    return  message['data']['documentId'];
  }
}

class IosFirebaseMessageParser extends FirebaseMessageParser {
  @override
  String parseDocumentId(Map<String, dynamic> message) {
    return message['documentId'];
  }
}