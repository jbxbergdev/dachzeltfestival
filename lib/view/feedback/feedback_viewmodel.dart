
import 'package:dachzeltfestival/repository/legal_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class FeedbackViewModel {

  final TextRepo _textRepo;

  FeedbackViewModel(this._textRepo);

  Stream<String> get markdown => _textRepo.feedbackMarkdown();

}