
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dachzeltfestival/model/geojson/feature.dart';
import 'package:dachzeltfestival/model/geojson/place_category.dart';
import 'package:dachzeltfestival/view/exhibitor/exhibitors_viewmodel.dart';
import 'package:dachzeltfestival/view/place_selection_interactor.dart';
import 'package:dachzeltfestival/i18n/translations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:inject/inject.dart';
import 'package:url_launcher/url_launcher.dart';

typedef Provider<T> = T Function();

@provide
class ExhibitorsBuilder {
  final Provider<ExhibitorsViewModel> _vmProvider;
  final PlaceSelectionInteractor _placeSelectionInteractor;

  ExhibitorsBuilder(this._vmProvider, this._placeSelectionInteractor);

  Exhibitors build(Key key) => Exhibitors(_vmProvider(), _placeSelectionInteractor);
}

class Exhibitors extends StatelessWidget {

  final ExhibitorsViewModel _viewModel;
  final PlaceSelectionInteractor _placeSelectionInteractor;

  static const String _adDisclaimerUrl = 'https://dachzeltnomaden.com/werbepaket/';

  Exhibitors(this._viewModel, this._placeSelectionInteractor);

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
                double paddingAbove = index == 0 ? 8.0 : 2.0;
                double paddingBelow = index == snapshot.data.length - 1 ? 8.0 : 2.0;
                return Padding(
                  padding: EdgeInsets.only(left: 8.0, top: paddingAbove, right: 8.0, bottom: paddingBelow),
                  child: Card(
                    elevation: 2.0,
                    child: Material(
                      child: InkWell(
                        onTap: () => _placeSelectionInteractor.selectedPlaceId.add(item.properties.placeId),
                        child: item.properties.mappedCategory == PlaceCategory.PREMIUM_EXHIBITOR ? _premiumExhibitor(item, context) : _exhibitor(item),
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

  Widget _premiumExhibitor(Feature feature, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                child: Expanded(
                  child: Container(),
                ),
              ),
              Material(
                child: InkWell(
                  onTap: () => launch(_adDisclaimerUrl),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            context.translations[AppString.advertisement],
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 8.0,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 2.0),
                            child: Icon(
                              Icons.info_outline,
                              size: 8.0,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _logoAndName(feature),
          ),
          Container(
            height: 20.0,
          ),
        ],
      ),
    );
  }

  Widget _exhibitor(Feature feature) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: _logoAndName(feature),
    );
  }

  Widget _logoAndName(Feature feature) {
    return Row(
      children: <Widget>[
        feature.properties.logoUrl != null
            ? Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CachedNetworkImage(
            imageUrl: feature.properties.logoUrl,
            height: 48,
            width: 48,
            fit: BoxFit.contain,
          ),
        )
            : Container(),
        Container(
          child: Expanded(
            child: Text(
              feature.properties.name,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
      ],
    );
  }
}