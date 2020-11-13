import 'package:dachzeltfestival/model/configuration/charity_config.dart';
import 'package:dachzeltfestival/repository/charity_repo.dart';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

@injectable
class CharityViewModel {

  final CharityRepo _charityRepo;

  CharityViewModel(this._charityRepo);

  Stream<CharityConfig> get charityConfig => _charityRepo.charityConfig;
}