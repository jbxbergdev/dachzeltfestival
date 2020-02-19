import 'dart:collection';
import 'dart:math';
import 'dart:ui';

import 'package:dachzeltfestival/model/geojson/place_category.dart';
import 'package:dachzeltfestival/view/map/icon_map.dart';
import 'package:dachzeltfestival/view/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inject/inject.dart';
import 'package:rxdart/rxdart.dart';

@provide
@singleton
class PointCategoryIcons {

  final BehaviorSubject<Map<PlaceCategory, SelectionBitmapDescriptors>> _bitmapSubject = BehaviorSubject.seeded(null);

  PointCategoryIcons() {
    _createBitmapMapping().then((mapping) => _bitmapSubject.value = mapping);
  }

  Future<Map<PlaceCategory, SelectionBitmapDescriptors>> get bitmapMapping =>
      _bitmapSubject.where((mapping) => mapping != null).first;

  Future<Map<PlaceCategory, SelectionBitmapDescriptors>> _createBitmapMapping() async {
    final unselectedGenerator = _BitmapGenerator(72.0);
    final selectedGenerator = _BitmapGenerator(96.0);

    Map<PlaceCategory, SelectionBitmapDescriptors> bitmapMap = HashMap();
    for (MapEntry<PlaceCategory, IconInfo> entry in iconDataMap.entries) {
      final unselected = await unselectedGenerator._createBitmapFromIconData(entry.value.icon, entry.value.color, appTheme.colorScheme.primary, Colors.white);
      final selected = await selectedGenerator._createBitmapFromIconData(entry.value.icon, entry.value.color, appTheme.colorScheme.secondary, Colors.white);
      bitmapMap[entry.key] = SelectionBitmapDescriptors(selected, unselected);
    }
    return bitmapMap;
  }
}

class _BitmapGenerator {

  final BehaviorSubject<Map<PlaceCategory, BitmapDescriptor>> _bitmapSubject = BehaviorSubject.seeded(null);

  final double _rectSize;
  double _circleStrokeWidth;
  double _circleOffset;
  double _outlineCircleWidth;
  double _fillCircleWidth;
  double _iconSize;
  double _iconOffset;

  _BitmapGenerator(this._rectSize) {
    _circleStrokeWidth = _rectSize / 10.0;
    _circleOffset = _rectSize / 2;
    _outlineCircleWidth = _circleOffset - (_circleStrokeWidth / 2);
    _fillCircleWidth = _rectSize / 2;
    var outlineCircleInnerWidth = _rectSize - (2 * _circleStrokeWidth);
    _iconSize = sqrt(pow(outlineCircleInnerWidth, 2) / 2);
    var rectDiagonal = sqrt(2 * pow(_rectSize, 2));
    var circleDistanceToCorners = (rectDiagonal - outlineCircleInnerWidth) / 2;
    _iconOffset = sqrt(pow(circleDistanceToCorners, 2) / 2);
  }

  Future<BitmapDescriptor> _createBitmapFromIconData(IconData iconData, Color iconColor, Color circleColor, Color backgroundColor) async {
    var pictureRecorder = PictureRecorder();
    var canvas = Canvas(pictureRecorder);

    _paintCircleFill(canvas, backgroundColor);
    _paintCircleStroke(canvas, circleColor);
    _paintIcon(canvas, iconColor, iconData);

    var picture = pictureRecorder.endRecording();
    var image = await picture.toImage(_rectSize.round(), _rectSize.round());
    var bytes = await image.toByteData(format: ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
  }

  void _paintCircleFill(Canvas canvas, Color color) {
    var paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
    canvas.drawCircle(Offset(_circleOffset, _circleOffset), _fillCircleWidth, paint);
  }

  void _paintCircleStroke(Canvas canvas, Color color) {
    var paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = _circleStrokeWidth;
    canvas.drawCircle(Offset(_circleOffset, _circleOffset), _outlineCircleWidth, paint);
  }

  void _paintIcon(Canvas canvas, Color color, IconData iconData) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          letterSpacing: 0.0,
          fontSize: _iconSize,
          fontFamily: iconData.fontFamily,
          color: color,
        )
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(_iconOffset, _iconOffset));
  }

}

class SelectionBitmapDescriptors {
  final BitmapDescriptor selected;
  final BitmapDescriptor unselected;

  SelectionBitmapDescriptors(this.selected, this.unselected);
}