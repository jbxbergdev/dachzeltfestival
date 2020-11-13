
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injector.config.dart';

@injectableInit
void configureDependencies() {
  $initGetIt(GetIt.instance);
  _getIt = GetIt.instance;
}

GetIt _getIt;

void initGetIt(GetIt getIt) => _getIt = getIt;

T inject<T>() => _getIt.get<T>();