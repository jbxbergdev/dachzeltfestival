// Flutter code sample for material.BottomNavigationBar.1

// This example shows a [BottomNavigationBar] as it is used within a [Scaffold]
// widget. The [BottomNavigationBar] has three [BottomNavigationBarItem]
// widgets and the [currentIndex] is set to index 0. The selected item is
// amber. The `_onItemTapped` function changes the selected item's index
// and displays a corresponding message in the center of the [Scaffold].
//
// ![A scaffold with a bottom navigation bar containing three bottom navigation
// bar items. The first one is selected.](https://flutter.github.io/assets-for-api-docs/assets/material/bottom_navigation_bar.png)

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'di/app_injector.dart';
import 'package:inject/inject.dart';
import 'i18n/translations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'view/main_widget.dart';
import 'view/theme.dart';

void main() async {
  AppInjector appInjector = await AppInjector.create();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(appInjector.app);
}

FirebaseAnalytics _firebaseAnalytics = FirebaseAnalytics();

@provide
class MyApp extends StatelessWidget {

  final MainWidgetBuilder _myStatefulWidgetBuilder;

  MyApp(this._myStatefulWidgetBuilder);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => context.translations[AppString.appName],
      navigatorObservers: <NavigatorObserver>[
        FirebaseAnalyticsObserver(analytics: _firebaseAnalytics),
      ],
      home: _myStatefulWidgetBuilder.build(),
      supportedLocales: Translations.supportedLanguages.map((language)  => Locale(language)),
      localizationsDelegates: [TranslationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
      ],
      theme: appTheme,
    );
  }
}