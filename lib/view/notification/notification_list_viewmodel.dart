import 'package:dachzeltfestival/model/notification/notification.dart' as notification;
import 'package:dachzeltfestival/repository/notification_repo.dart';
import 'package:rxdart/rxdart.dart';

class NotificationListViewModel {

  final NotificationRepo _notificationRepo;

  NotificationListViewModel(this._notificationRepo);

  Observable<List<notification.Notification>> notifications() => _notificationRepo.allNotifications();
}