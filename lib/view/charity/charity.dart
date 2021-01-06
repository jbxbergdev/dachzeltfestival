import 'package:dachzeltfestival/di/injector.dart';
import 'package:dachzeltfestival/model/configuration/charity_config.dart';
import 'package:dachzeltfestival/view/charity/charity_viewmodel.dart';
import 'package:dachzeltfestival/view/theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Charity extends StatelessWidget {

  Charity(Key key): super(key: key);

  @override
  Widget build(BuildContext context) {
    final appTheme = inject<AppTheme>();
    final charityViewModel = inject<CharityViewModel>();
    return StreamBuilder<CharityConfig>(
      stream: charityViewModel.charityConfig,
      builder: (buildContext, snapshot) {
        if (snapshot.hasData) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              'assets/images/charity_banner.jpg',
                            ),
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 12.0),
                          child: Text(
                            snapshot.data.titleText,
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 5.0,
                                  color: Colors.black,
                                  offset: Offset(2.0, 2.0),
                                ),
                              ]
                            ),
                          ),
                        ),
                        height: 150,
                        alignment: Alignment.bottomLeft,
                      ),
                    )
                  ]
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          snapshot.data.explanationText,
                          style: TextStyle (
                            fontSize: 16,
                            color: appTheme.current.colorScheme.onBackground
                          ),
                        ),
                      ),
                    )
                  ],
                ),
//                Expanded(
                        /*child:*/ Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: MaterialButton(
                              child: Text(snapshot.data.buttonText.toUpperCase()),
                              color: Theme.of(context).accentColor,
                              onPressed: () => launch(snapshot.data.buttonLink),
                            ),
                          ),
                        ),
//                    )
              ],
            ),
          );
        }
        return Text("");
      },
    );
  }

}