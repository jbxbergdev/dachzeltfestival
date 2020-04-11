import 'package:dachzeltfestival/util/custom_markers_icons.dart';
import 'package:dachzeltfestival/view/builders.dart';
import 'package:dachzeltfestival/model/configuration/app_config.dart';
import 'package:dachzeltfestival/view/main_viewmodel.dart';
import 'package:dachzeltfestival/view/notification/notification_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rxdart/rxdart.dart';
import 'package:inject/inject.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:dachzeltfestival/i18n/translations.dart';

typedef Provider<T> = T Function();

@provide
class MainWidgetBuilder {

  final MainLevelBuilders _builders;
  final Provider<MainViewModel> _vmProvider;

  MainWidgetBuilder(this._builders, this._vmProvider);

  MainWidget build() => MainWidget(_builders, _vmProvider);
}

class MainWidget extends StatefulWidget {

  final MainLevelBuilders _builders;
  final Provider<MainViewModel> _vmProvider;

  MainWidget(this._builders, this._vmProvider);

  @override
  _MainWidgetState createState() => _MainWidgetState(_builders, _vmProvider());
}

class _MainWidgetState extends State<MainWidget> {

  final MainLevelBuilders _builders;
  final MainViewModel _mainViewModel;
  final PageStorageBucket pageStorageBucket = PageStorageBucket();
  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(
      fontSize: 30, fontWeight: FontWeight.bold);

  _MainWidgetState(this._builders, this._mainViewModel);

  List<Widget> _pages;

  final CompositeSubscription _compositeSubscription = CompositeSubscription();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    _initNotificationHandling(context);
    _pages = <Widget>[
      _builders.notificationListBuilder.build(PageStorageKey('NotificationList')),
      _builders.eventMapBuilder.build(PageStorageKey('Map')),
      _builders.scheduleBuilder.build(PageStorageKey('Schedule')),
//      _builders.feedBuilder.build(PageStorageKey('Feed')),
      _builders.infoBuilder.build((PageStorageKey('Info'))),
    ];
    _compositeSubscription.add(_mainViewModel.placeSelectionInteractor.selectedPlaceId
        .where((selectedPlaceId) => selectedPlaceId != null)
        .listen((_) => this._onPlaceSelected()));
  }

  @override
  Widget build(BuildContext context) {
    _mainViewModel.localeSink.add(Localizations.localeOf(context));
    return StreamBuilder<AppConfig>(
        stream: _mainViewModel.appConfig,
        builder: (context, snapshot) {
          bool versionSupported = snapshot.data?.versionSupported != false;
          return  Scaffold(
              appBar: AppBar(
                title: RichText(
                  text: TextSpan(
                      style: GoogleFonts.adventPro(
                          textStyle: TextStyle(
                              fontFamily: 'AdventPro',
                            fontSize: 24,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      children: <TextSpan>[
                        TextSpan(
                            text: "#dzf",
                            style: TextStyle(
                                color: Colors.black
                            )
                        ),
                        TextSpan(
                            text: "20",
                            style: TextStyle(
                                color: Theme
                                    .of(context)
                                    .primaryColor
                            )
                        )
                      ]
                  ),
                ),
                leading: InkWell(
                  onTap: () => _onItemTapped(0),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, top: 8.0, bottom: 8.0),
                    child: Image.asset('assets/images/ic_logo.png'),
                  ),
                ),
              ),
              body: versionSupported ? IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ) : Center(child: Text(snapshot.data.deprecationInfo, textAlign: TextAlign.center,)),
              bottomNavigationBar: versionSupported ? BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.notifications_none),
                    title: Text(context.translations[AppString.notificationListTitle]),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.map),
                    title: Text(context.translations[AppString.navItemMap]),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.event),
                    title: Text(context.translations[AppString.navItemSchedule]),
                  ),
//                  BottomNavigationBarItem(
//                    icon: Icon(CustomMarkers.hash),
//                    title: Text(context.translations[AppString.feed]),
//                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.arrow_forward),
                    title: Text(context.translations[AppString.navItemMore]),
                  ),
                ],
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
              ) : null,
          );
        });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 1) {
        _mainViewModel.requestLocationPermission();
      }
    });
  }

  void _onPlaceSelected() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    _onItemTapped(1);
  }

  void _initNotificationHandling(BuildContext context) {
    _compositeSubscription.add(_mainViewModel.notifications.listen((notification) => showNotificationDialog(notification, context)));
  }

  @override
  void dispose() {
    _compositeSubscription.dispose();
    super.dispose();
  }
}
