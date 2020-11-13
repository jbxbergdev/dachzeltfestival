import 'package:dachzeltfestival/view/place_selection_interactor.dart';
import 'package:dachzeltfestival/repository/schedule_repo.dart';
import 'package:dachzeltfestival/model/schedule/schedule_item.dart';
import 'package:injectable/injectable.dart';

@injectable
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