import 'package:dachzeltfestival/repository/event_info_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class EventInfoViewModel {
  final EventInfoRepo _eventInfoRepo;

  EventInfoViewModel(this._eventInfoRepo);

  Stream<String> get markdown => _eventInfoRepo.eventInfoMarkup;
}