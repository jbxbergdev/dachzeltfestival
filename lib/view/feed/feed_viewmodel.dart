
import 'package:dachzeltfestival/repository/feed_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class FeedViewModel {

  final FeedRepo _feedRepo;

  FeedViewModel(this._feedRepo);

  Stream<String> get feedHtml => _feedRepo.feedHtml;
}