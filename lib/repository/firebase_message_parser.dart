import 'package:dachzeltfestival/model/notification/notification.dart';

abstract class FirebaseMessageParser {
  Notification parse(Map<String, dynamic> message);
}

class AndroidFirebaseMessageParser extends FirebaseMessageParser {
  @override
  Notification parse(Map<String, dynamic> message) {
    return Notification(
      message['data']['title'],
      message['data']['body'],
      message['data']['url'],
    );
  }
}

class IosFirebaseMessageParser extends FirebaseMessageParser {
  @override
  Notification parse(Map<String, dynamic> message) {
    return Notification(
      message['title'],
      message['body'],
      message['url'],
    );
  }

}