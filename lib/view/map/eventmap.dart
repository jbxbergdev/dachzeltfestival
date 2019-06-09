import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'eventmap_viewmodel.dart';
import 'geojson_gmaps_converter.dart';
import 'package:inject/inject.dart';
import 'package:dachzeltfestival/model/geojson/feature.dart' as geojson;
import 'package:rubber/rubber.dart';
import 'package:rxdart/rxdart.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';

typedef Provider<T> = T Function();

@provide
class EventMapBuilder {
  final Provider<EventMapViewModel> _vmProvider;
  final FeatureConverter _featureConverter;
  EventMapBuilder(this._vmProvider, this._featureConverter);

  EventMap build(Key key) => EventMap(key, _vmProvider, _featureConverter);
}

class EventMap extends StatefulWidget {

  final Provider<EventMapViewModel> _vmProvider;
  final FeatureConverter _featureConverter;

  EventMap(Key key, this._vmProvider, this._featureConverter): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EventMapState(_vmProvider(), _featureConverter);
  }
}

class _EventMapState extends State<EventMap> with SingleTickerProviderStateMixin {

  GoogleMapController _googleMapController;
  CameraPosition _cameraPosition = CameraPosition(
    target: LatLng(49.137756, 10.876035),
    zoom: 16.0,
  );
  final EventMapViewModel _eventMapViewModel;
  final FeatureConverter _featureConverter;
  RubberAnimationController _controller;
  ScrollController _scrollController = ScrollController();
  BehaviorSubject<geojson.Properties> _propertiesSubject;

  _EventMapState(this._eventMapViewModel, this._featureConverter);

  @override
  void initState() {
    super.initState();
    _propertiesSubject = BehaviorSubject.seeded(null);
    _controller = RubberAnimationController(
        vsync: this,
        halfBoundValue: AnimationControllerValue(percentage: 0.5),
        lowerBoundValue: AnimationControllerValue(percentage: 0.0),
        duration: Duration(milliseconds: 200),
        initialValue: 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {

    return RubberBottomSheet(
      scrollController: _scrollController,
      lowerLayer: StreamBuilder<Set<Polygon>>(
          stream: _eventMapViewModel.observeMapFeatures()
              .asyncMap((featureCollection) => _featureConverter.parseFeatureCollection(featureCollection, _onPolygonTapped)),
          builder: (buildContext, snapshot) {
            return GoogleMap(
              initialCameraPosition: _cameraPosition,
              myLocationEnabled: true,
              polygons: snapshot.data ?? Set(),
              onMapCreated: _onMapCreated,
              onCameraMove: _onCameraMove,
              onTap: _onTap,
            );
          }),
      header: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10)
              )
          ),
          child: StreamBuilder<geojson.Properties>(
            initialData: geojson.Properties(),
            stream: _propertiesSubject.stream,
            builder: (buildContext, snapshot) {
              return Container(child: Text(snapshot.data?.name ?? ""));
            },
          ),
        ),
      ),
      headerHeight: 60,
      upperLayer: StreamBuilder<geojson.Properties>(
        stream: _propertiesSubject.stream,
        builder: (buildContext, snapshot) {
//          String url = Uri.dataFromString(snapshot.data?.description ?? "<p>", mimeType: 'text/
        HtmlEscape(HtmlEscapeMode(
          escapeLtGt: false,
          escapeQuot: true
        ));
        String url = Uri.dataFromString("<html><body><p>Bla bla bla<br>bla blaüüää</body></html>", mimeType: 'text/html').toString();
          return WebView(
            initialUrl: url,
          );
        },
      ),
      animationController: _controller,
    );
  }

  void _onPolygonTapped(geojson.Properties properties) {
    _propertiesSubject.add(properties);
    _controller.animateTo(to: 0.5);
  }

  void _onMapCreated(GoogleMapController controller) {
    _googleMapController = controller;
  }

  void _onCameraMove(CameraPosition cameraPosition) {
    _cameraPosition = cameraPosition;
  }

  void _onTap(LatLng tapCoords) {
    _controller.collapse();
  }


}