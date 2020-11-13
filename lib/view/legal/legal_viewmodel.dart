import 'dart:ui';

import 'package:dachzeltfestival/repository/legal_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class LegalViewModel {

  final TextRepo _legalRepo;

  LegalViewModel(this._legalRepo);

  Stream<String> legalMarkdown() => _legalRepo.legalMarkdown();
}