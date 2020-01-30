import 'package:dachzeltfestival/view/charity/charity.dart';
import 'package:dachzeltfestival/view/more/more.dart';
import 'package:dachzeltfestival/view/legal/legal.dart';
import 'package:dachzeltfestival/view/map/eventmap.dart';
import 'package:dachzeltfestival/view/notification/notification_list.dart';
import 'package:dachzeltfestival/view/schedule/schedule.dart';
import 'package:inject/inject.dart';

@provide
class MainLevelBuilders {

  final EventMapBuilder _eventMapBuilder;
  final ScheduleBuilder _scheduleBuilder;
  final CharityBuilder _charityBuilder;
  final LegalBuilder _legalBuilder;
  final MoreBuilder _infoBuilder;
  final NotificationListBuilder _notificationListBuilder;

  MainLevelBuilders(this._eventMapBuilder, this._scheduleBuilder, this._charityBuilder, this._legalBuilder, this._infoBuilder, this._notificationListBuilder);

  EventMapBuilder get eventMapBuilder => _eventMapBuilder;

  ScheduleBuilder get scheduleBuilder => _scheduleBuilder;

  CharityBuilder get charityBuilder => _charityBuilder;

  LegalBuilder get legalBuilder => _legalBuilder;

  MoreBuilder get infoBuilder => _infoBuilder;

  NotificationListBuilder get notificationListBuilder => _notificationListBuilder;
}