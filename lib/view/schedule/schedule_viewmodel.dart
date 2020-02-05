import 'package:dachzeltfestival/view/place_selection_interactor.dart';
import 'package:inject/inject.dart';
import 'package:dachzeltfestival/repository/schedule_repo.dart';
import 'package:dachzeltfestival/model/schedule/schedule_item.dart';
import 'package:rxdart/rxdart.dart';

@provide
class ScheduleViewModel {
  final ScheduleRepo _scheduleRepo;
  final PlaceSelectionInteractor _placeSelectionInteractor;

  ScheduleViewModel(this._scheduleRepo, this._placeSelectionInteractor);

  Stream<List<ScheduleItem>> observeSchedule() {
    return _scheduleRepo.observeSchedule();
  }

  Stream<DateTime> currentTimeMinuteInterval() => Stream.periodic(Duration(seconds: 1))
      .map((_) => DateTime.now())
      .distinct((previous, next) => previous.minute == next.minute);

  PlaceSelectionInteractor get placeSelectionInteractor => _placeSelectionInteractor;
}