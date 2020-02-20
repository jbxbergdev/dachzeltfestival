
import 'package:dachzeltfestival/model/geojson/feature.dart';
import 'package:dachzeltfestival/view/exhibitor/exhibitors_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:inject/inject.dart';

typedef Provider<T> = T Function();

@provide
class ExhibitorsBuilder {
  final Provider<ExhibitorsViewModel> _vmProvider;

  ExhibitorsBuilder(this._vmProvider);

  Exhibitors build(Key key) => Exhibitors(_vmProvider());
}

class Exhibitors extends StatelessWidget {

  final ExhibitorsViewModel _viewModel;

  Exhibitors(this._viewModel);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Feature>>(
      stream: _viewModel.exhibitors(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                Feature item = snapshot.data[index];
                double paddingAbove = index == 0 ? 12.0 : 4.0;
                double paddingBelow = index == snapshot.data.length - 1 ? 12.0 : 4.0;
                return Padding(
                  padding: EdgeInsets.only(left: 8.0, top: paddingAbove, right: 8.0, bottom: paddingBelow),
                  child: Card(
                    elevation: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      item.properties.name,
                                      style: TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
        return Container();
      },
    );
  }
}