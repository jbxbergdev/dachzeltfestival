// Flutter code sample for material.BottomNavigationBar.1

// This example shows a [BottomNavigationBar] as it is used within a [Scaffold]
// widget. The [BottomNavigationBar] has three [BottomNavigationBarItem]
// widgets and the [currentIndex] is set to index 0. The selected item is
// amber. The `_onItemTapped` function changes the selected item's index
// and displays a corresponding message in the center of the [Scaffold].
//
// ![A scaffold with a bottom navigation bar containing three bottom navigation
// bar items. The first one is selected.](https://flutter.github.io/assets-for-api-docs/assets/material/bottom_navigation_bar.png)

import 'package:flutter/material.dart';
import 'view/map/eventmap.dart';
import 'di/app_injector.dart';
import 'package:inject/inject.dart';
import 'view/schedule/schedule.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'i18n/translations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  AppInjector appInjector = await AppInjector.create();
  runApp(appInjector.app);
}

@provide
class MyApp extends StatelessWidget {

  final MyStatefulWidgetBuilder _myStatefulWidgetBuilder;

  MyApp(this._myStatefulWidgetBuilder);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => Translations.of(context).get(AppString.appName),
      home: _myStatefulWidgetBuilder.build(),
      supportedLocales: Translations.supportedLanguages.map((language)  => Locale(language)),
      localizationsDelegates: [TranslationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate],
    );
  }
}

@provide
class MyStatefulWidgetBuilder {

  final EventMapBuilder _eventMapBuilder;
  final ScheduleBuilder _scheduleBuilder;

  MyStatefulWidgetBuilder(this._eventMapBuilder, this._scheduleBuilder);

  MyStatefulWidget build() => MyStatefulWidget(_eventMapBuilder, _scheduleBuilder);
}

class MyStatefulWidget extends StatefulWidget {

  final EventMapBuilder _eventMapBuilder;
  final ScheduleBuilder _scheduleBuilder;

  MyStatefulWidget(this._eventMapBuilder, this._scheduleBuilder);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState(_eventMapBuilder, _scheduleBuilder);
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {

  final EventMapBuilder _eventMapBuilder;
  final ScheduleBuilder _scheduleBuilder;
  final PageStorageBucket pageStorageBucket = PageStorageBucket();
  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  _MyStatefulWidgetState(this._eventMapBuilder, this._scheduleBuilder);

  List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    _pages = <Widget>[
      _scheduleBuilder.build(PageStorageKey('Schedule')),
      _eventMapBuilder.build(PageStorageKey('Map')),
//      TestPage(key: PageStorageKey("TestPage"),),
      OverflowBox(
        key: PageStorageKey('Donate'),
        minWidth: 0.0,
        minHeight: 0.0,
        maxHeight: double.infinity,
        alignment: Alignment.topLeft,
        child: Image.asset('assets/images/donate_screenshot.png', fit: BoxFit.cover,),
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Translations translations = Translations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          translations.get(AppString.appName),
          style: TextStyle(
            fontFamily: 'RobotoLight',
            color: Color(0xFF000000)
          ),
        ),
        backgroundColor: Color(0xFFFFFFFF),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            title: Text(translations.get(AppString.navItemSchedule)),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            title: Text(translations.get(AppString.navItemMap)),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            title: Text(translations.get(AppString.navItemDonate)),
          ),
        ],
        currentIndex: _selectedIndex,
        fixedColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}