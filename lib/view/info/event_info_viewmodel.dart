import 'package:dachzeltfestival/repository/event_info_repo.dart';
import 'package:inject/inject.dart';
import 'package:rxdart/rxdart.dart';

@provide
class EventInfoViewModel {
  final EventInfoRepo _eventInfoRepo;

  EventInfoViewModel(this._eventInfoRepo);

  Observable<String> get markdown => _eventInfoRepo.eventInfoMarkup;
}