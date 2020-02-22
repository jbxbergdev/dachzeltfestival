
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
              itemCount: snapshot.data.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0, top: 8.0),
                      child: Text(
                        context.translations[AppString.advertisement],
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 8.0,
                        ),
                      ),
                    ),
                  );
                }
                Feature item = snapshot.data[index - 1];
                double paddingAbove = 2.0;
                double paddingBelow = index == snapshot.data.length ? 8.0 : 2.0;
                return Padding(
                  padding: EdgeInsets.only(left: 8.0, top: paddingAbove, right: 8.0, bottom: paddingBelow),
                  child: Card(
                    elevation: 2.0,
                    child: Material(
                      child: InkWell(
                        onTap: () => _placeSelectionInteractor.selectedPlaceId.add(item.properties.placeId),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: item.properties.mappedCategory == PlaceCategory.PREMIUM_EXHIBITOR ? _premiumExhibitor(item) : _exhibitor(item),
                        ),
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

  Widget _premiumExhibitor(Feature feature) {
    return _exhibitor(feature); // TODO
  }

  Widget _exhibitor(Feature feature) {
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