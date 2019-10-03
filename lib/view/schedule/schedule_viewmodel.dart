import 'package:flutter/cupertino.dart';
import 'package:inject/inject.dart';
import 'package:dachzeltfestival/repository/schedule_repo.dart';
import 'package:dachzeltfestival/model/schedule/schedule_item.dart';
import 'package:rxdart/rxdart.dart';

@provide
class ScheduleViewModel {
  final ScheduleRepo _scheduleRepo;

  ScheduleViewModel(this._scheduleRepo);

  BehaviorSubject<Locale> get localeSubject {
    return _scheduleRepo.localeSubject;
  }

  Stream<List<ScheduleItem>> observeSchedule() {
    return _scheduleRepo.observeSchedule();
  }
}