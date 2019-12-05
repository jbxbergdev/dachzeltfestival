import 'package:dachzeltfestival/i18n/translations.dart';
import 'package:dachzeltfestival/model/configuration/charity_config.dart';
import 'package:dachzeltfestival/view/charity/charity_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:inject/inject.dart';
import 'package:url_launcher/url_launcher.dart';

typedef Provider<T> = T Function();

@provide
class CharityBuilder {
  final Provider<CharityViewModel> _vmProvider;

  CharityBuilder(this._vmProvider);

  Charity build(Key key) => Charity(_vmProvider());
}

class Charity extends StatelessWidget {

  final CharityViewModel _charityViewModel;

  Charity(this._charityViewModel);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CharityConfig>(
      stream: _charityViewModel.charityConfig,
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
                            color: Colors.grey[800]
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