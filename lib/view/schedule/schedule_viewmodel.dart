import 'package:inject/inject.dart';
import 'package:dachzeltfestival/repository/schedule_repo.dart';
import 'package:dachzeltfestival/model/schedule/schedule_item.dart';

@provide
class ScheduleViewModel {
  final ScheduleRepo _scheduleRepo;

  ScheduleViewModel(this._scheduleRepo);

  Stream<List<ScheduleItem>> observeSchedule() {
    return _scheduleRepo.observeSchedule();
  }
}