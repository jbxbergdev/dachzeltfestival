import 'dart:ui';

import 'package:dachzeltfestival/repository/legal_repo.dart';
import 'package:inject/inject.dart';
import 'package:rxdart/rxdart.dart';

@provide
class LegalViewModel {

  final TextRepo _legalRepo;

  LegalViewModel(this._legalRepo);

  Stream<String> legalMarkdown() => _legalRepo.legalMarkdown();
}