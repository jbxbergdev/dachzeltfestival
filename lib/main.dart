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
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'view/map/eventmap.dart';
import 'testui.dart';

void main() => runApp(MyApp());

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {

  final PageStorageBucket pageStorageBucket = PageStorageBucket();
  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  final List<Widget> pages = <Widget>[
    Image.asset(
      'assets/images/schedule_screenshot.png',
      key: PageStorageKey('Schedule'),
    ),
    EventMap(key: PageStorageKey('Map')),
    OverflowBox(
      key: PageStorageKey('Donate'),
      minWidth: 0.0,
      minHeight: 0.0,
      maxHeight: double.infinity,
      alignment: Alignment.topLeft,
      child: Image.asset('assets/images/donate_screenshot.png', fit: BoxFit.cover,),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dachzeltfestival 2020',
          style: TextStyle(
            fontFamily: 'RobotoLight',
            color: Color(0xFF000000)
          ),
        ),
        backgroundColor: Color(0xFFFFFFFF),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            title: Text('Programm'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            title: Text('Gelände'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            title: Text('Show Love'),
          ),
        ],
        currentIndex: _selectedIndex,
        fixedColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}