
import 'package:dachzeltfestival/repository/feed_repo.dart';
import 'package:inject/inject.dart';

@provide
class FeedViewModel {

  final FeedRepo _feedRepo;

  FeedViewModel(this._feedRepo);

  Stream<String> get feedHtml => _feedRepo.feedHtml;
}