import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'map/eventmap.dart';
import 'package:inject/inject.dart';
import 'schedule/schedule.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:dachzeltfestival/i18n/translations.dart';
import 'package:url_launcher/url_launcher.dart';

@provide
class MainWidgetBuilder {

  final EventMapBuilder _eventMapBuilder;
  final ScheduleBuilder _scheduleBuilder;

  MainWidgetBuilder(this._eventMapBuilder, this._scheduleBuilder);

  MainWidget build() => MainWidget(_eventMapBuilder, _scheduleBuilder);
}

class MainWidget extends StatefulWidget {

  final EventMapBuilder _eventMapBuilder;
  final ScheduleBuilder _scheduleBuilder;

  MainWidget(this._eventMapBuilder, this._scheduleBuilder);

  @override
  _MainWidgetState createState() => _MainWidgetState(_eventMapBuilder, _scheduleBuilder);
}

class _MainWidgetState extends State<MainWidget> {

  final EventMapBuilder _eventMapBuilder;
  final ScheduleBuilder _scheduleBuilder;
  final PageStorageBucket pageStorageBucket = PageStorageBucket();
  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  _MainWidgetState(this._eventMapBuilder, this._scheduleBuilder);

  List<Widget> _pages;

  final String _testerWelcomeText = "Hallo Dachzeltnomade,\n\n"
      "Vielen Dank, dass Du dir die Zeit nimmst, die App fürs Dachzeltfestival 2020 zu testen. Du siehst hier eine frühe Testversion. "
      "Du kannst aber schon jetzt den Programmkalender und die Event-Karte benutzen. Es werden in den nächsten Monaten noch ein paar coole Features "
      "dazu kommen. Hast du Feedback, Probleme oder Ideen für die App? Es würde mich freuen, von dir zu hören! Komm doch "
      "einfach auf dem Offroad-Camp vorbei (ich bin der Typ mit dem alten dunkelgrauen Volvo aus Berlin ;-) ), oder schreib mir eine Mail (Link unten). \n\n"
      "Viel Spaß und liebe Grüße,\nJohannes\n\n";

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    _pages = <Widget>[
      _scheduleBuilder.build(PageStorageKey('Schedule')),
      _eventMapBuilder.build(PageStorageKey('Map')),
//      TestPage(key: PageStorageKey("TestPage"),),
//      OverflowBox(
//        key: PageStorageKey('Donate'),
//        minWidth: 0.0,
//        minHeight: 0.0,
//        maxHeight: double.infinity,
//        alignment: Alignment.topLeft,
//        child: Image.asset('assets/images/donate_screenshot.png', fit: BoxFit.cover,),
//      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: RichText(
          key: PageStorageKey('Donate'),
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                style: TextStyle(
                  color: Colors.black,
                ),
                text: _testerWelcomeText
              ),
              TextSpan(
                text: "Email",
                style: TextStyle(
                  color: Colors.blue,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => launch("mailto:kontakt@johannes-bolz.de")
              )
            ]
          ),
        ),
      )
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
        title: RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'AdventPro',
                fontSize: 24,
                fontWeight: FontWeight.w500
              ),
              children: <TextSpan>[
                TextSpan(
                  text: "#dz",
                  style: TextStyle(
                    color: Colors.black
                  )
                ),
                TextSpan(
                  text: "oc",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor
                  )
                )
              ]
            ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
          child: Image.asset('assets/images/ic_logo.png'),
        ),
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
        onTap: _onItemTapped,
      ),
    );
  }
}