
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

@singleton
class PlaceSelectionInteractor {
  // ignore: close_sinks
  final BehaviorSubject<String> selectedPlaceId = BehaviorSubject();
}