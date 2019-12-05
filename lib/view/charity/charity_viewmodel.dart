import 'package:dachzeltfestival/model/configuration/charity_config.dart';
import 'package:dachzeltfestival/repository/charity_repo.dart';
import 'package:flutter/cupertino.dart';
import 'package:inject/inject.dart';
import 'package:rxdart/rxdart.dart';

@provide
class CharityViewModel {

  final CharityRepo _charityRepo;

  CharityViewModel(this._charityRepo);

  Observable<CharityConfig> get charityConfig => _charityRepo.charityConfig;
}