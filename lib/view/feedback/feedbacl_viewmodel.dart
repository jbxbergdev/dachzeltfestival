
import 'package:dachzeltfestival/repository/legal_repo.dart';
import 'package:inject/inject.dart';
import 'package:rxdart/rxdart.dart';

@provide
class FeedbackViewModel {

  final TextRepo _textRepo;

  FeedbackViewModel(this._textRepo);

  Stream<String> get markdown => _textRepo.feedbackMarkdown();

}