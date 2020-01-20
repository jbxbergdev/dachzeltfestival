
import 'package:inject/inject.dart';
import 'package:rxdart/rxdart.dart';

@provide
@singleton
class PlaceSelectionInteractor {
  // ignore: close_sinks
  final PublishSubject<String> selectedPlaceId = PublishSubject();
}