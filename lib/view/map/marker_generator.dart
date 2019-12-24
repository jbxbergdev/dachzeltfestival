import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerGenerator {

  final _rectSize = 100.0;
  final _circleStrokeWidth = 10.0;
  double _circleOffset;
  double _outlineCircleWidth;
  double _fillCircleWidth;
  double _iconSize;
  double _iconOffset;

  MarkerGenerator() {
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

  void _tempPaintStuff(Canvas canvas, IconData iconData) {
    _paintCircleFill(canvas, Colors.white);
    _paintCircleStroke(canvas, Colors.blue);
    _paintIcon(canvas, Colors.red, iconData);
  }

}



class TestPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    MarkerGenerator()._tempPaintStuff(canvas, Icons.feedback);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}