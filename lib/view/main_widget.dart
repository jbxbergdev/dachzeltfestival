import 'package:dachzeltfestival/model/configuration/app_config.dart';
import 'package:dachzeltfestival/view/charity/charity.dart';
import 'package:dachzeltfestival/view/main_viewmodel.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'map/eventmap.dart';
import 'package:inject/inject.dart';
import 'schedule/schedule.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:dachzeltfestival/i18n/translations.dart';

typedef Provider<T> = T Function();

@provide
class MainWidgetBuilder {

  final EventMapBuilder _eventMapBuilder;
  final ScheduleBuilder _scheduleBuilder;
  final CharityBuilder _charityBuilder;
  final Provider<MainViewModel> _vmProvider;

  MainWidgetBuilder(this._eventMapBuilder, this._scheduleBuilder, this._charityBuilder, this._vmProvider);

  MainWidget build() => MainWidget(_eventMapBuilder, _scheduleBuilder, _charityBuilder, _vmProvider);
}

class MainWidget extends StatefulWidget {

  final EventMapBuilder _eventMapBuilder;
  final ScheduleBuilder _scheduleBuilder;
  final CharityBuilder _charityBuilder;
  final Provider<MainViewModel> _vmProvider;

  MainWidget(this._eventMapBuilder, this._scheduleBuilder, this._charityBuilder, this._vmProvider);

  @override
  _MainWidgetState createState() => _MainWidgetState(_eventMapBuilder, _scheduleBuilder, _charityBuilder, _vmProvider());
}

class _MainWidgetState extends State<MainWidget> {

  final EventMapBuilder _eventMapBuilder;
  final ScheduleBuilder _scheduleBuilder;
  final CharityBuilder _charityBuilder;
  final MainViewModel _mainViewModel;
  final PageStorageBucket pageStorageBucket = PageStorageBucket();
  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(
      fontSize: 30, fontWeight: FontWeight.bold);

  _MainWidgetState(this._eventMapBuilder, this._scheduleBuilder, this._charityBuilder, this._mainViewModel);

  List<Widget> _pages;

  final String _testerWelcomeText = "Hallo Dachzeltnomade,\n\n"
      "Hier ist Johannes, der Entwickler dieser App. Vielen Dank, dass Du diese Betaversion testest. Ich würde mich sehr über dein Feedback freuen. "
      "Komm doch im Camp vorbei (ich bin der Typ mit dem alten dunkelgrauen Volvo aus Berlin ;-) ), oder schreib mich an: \n\n";

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    _pages = <Widget>[
      _scheduleBuilder.build(PageStorageKey('Schedule')),
      _eventMapBuilder.build(PageStorageKey('Map')),
      _charityBuilder.build(PageStorageKey('Charity')),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: RichText(
          key: PageStorageKey('Feedback'),
          text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    text: _testerWelcomeText
                ),
                TextSpan(
                    text: "WhatsApp",
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => launch("https://wa.me/491621838910")
                ),
                TextSpan(
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    text: "\n\n"
                ),
                TextSpan(
                    text: "Instagram",
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => launch("https://www.instagram.com/jbxplores/")
                ),
                TextSpan(
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    text: "\n\n"
                ),
                TextSpan(
                    text: "Facebook",
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => launch("http://m.me/johnnyyenagain")
                ),
                TextSpan(
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    text: "\n\n"
                ),
                TextSpan(
                    text: "Email",
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => launch("mailto:kontakt@johannes-bolz.de")
                ),
                TextSpan(
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    text: "\n\nViel Spaß und liebe Grüße,\nJohannes"
                ),
              ]
          ),
        ),
      ),
      WebView(
        key: PageStorageKey("WebView"),
        initialUrl: _url,
        javascriptMode: JavascriptMode.unrestricted,
        navigationDelegate: (navigationRequest) {
          if (navigationRequest.url == _url) {
            return NavigationDecision.navigate;
          }
          launch(navigationRequest.url);
          return NavigationDecision.prevent;
        },
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
    _mainViewModel.localeSubject.value = Localizations.localeOf(context);
    return StreamBuilder<AppConfig>(
        stream: _mainViewModel.appConfig,
        builder: (context, snapshot) {
          bool versionSupported = snapshot.data?.versionSupported != false;
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
                          text: "#dzc",
                          style: TextStyle(
                              color: Colors.black
                          )
                      ),
                      TextSpan(
                          text: "speciaal",
                          style: TextStyle(
                              color: Theme
                                  .of(context)
                                  .primaryColor
                          )
                      )
                    ]
                ),
              ),
              leading: Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, top: 8.0, bottom: 8.0),
                child: Image.asset('assets/images/ic_logo.png'),
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
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  title: Text(translations.get(AppString.navItemAbout)),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.ac_unit),
                  title: Text("WebView"),
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            ) : null,
          );
        });
  }

  final String _url = Uri.dataFromString(_html, mimeType: "text/html").toString();


  static const String _html = '''<html>
  <head><meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no" /></head>
  <div id="flockler_container"></div>
<script type="text/javascript">
  var _flockler = _flockler || [];
  _flockler.push({
    count: 12,
    refresh: 10000,
    refreshType: 'auto',
    infiniteScroll: 1,
    site: *hidden*,
    style: 'wall_v1',
    showLikes: 1,
    showComments: 1,
    showRetweets: 1,
  });
  (function(d){var f = d.createElement('script');f.async=1;f.src='https://embed-cdn.flockler.com/embed-v2.js';s=d.getElementsByTagName('script')[0];s.parentNode.insertBefore(f,s);})(document);
</script>
<style>
  .flockler-wall-item__media + .flockler-wall-item__body,
  .flockler-wall-item__media + .flockler-wall-item__body + .flockler-wall-item__showmore {
    display: none !important;
  }
</style></html>''';
}