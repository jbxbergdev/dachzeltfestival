import 'package:dachzeltfestival/model/notification/notification.dart' as notification;
import 'package:dachzeltfestival/repository/notification_repo.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

@injectable
class NotificationListViewModel {

  final NotificationRepo _notificationRepo;

  NotificationListViewModel(this._notificationRepo);

  Stream<List<notification.Notification>> notifications() => _notificationRepo.allNotifications();
}