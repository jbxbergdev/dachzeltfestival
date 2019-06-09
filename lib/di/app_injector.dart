import 'package:inject/inject.dart';
import 'package:dachzeltfestival/di/module.dart';
import 'package:dachzeltfestival/main.dart';

import 'app_injector.inject.dart' as g;

@Injector([AppModule])
abstract class AppInjector {

  @provide
  MyApp get app;

  static Future<AppInjector> create() {
    return g.AppInjector$Injector.create(AppModule());
  }

}