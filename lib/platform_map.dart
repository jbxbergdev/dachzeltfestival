import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

typedef void OnPlatformViewCreated(PlatformMapController platformMapController);

class PlatformMap extends StatefulWidget {

  final OnPlatformViewCreated onPlatformViewCreated;

  PlatformMap({
    Key key,
    @required this.onPlatformViewCreated,
  });

  @override
  State<StatefulWidget> createState() => _PlatformMapState();

}

class _PlatformMapState extends State<PlatformMap> {
  @override
  Widget build(BuildContext context) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
          viewType: 'platformMap',
          onPlatformViewCreated: onPlatformViewCreated,
          creationParamsCodec: new StandardMessageCodec(),
        );
      default:
        return Text('PlatformMap not implemented for $defaultTargetPlatform');
        // TODO iOS
    }
  }

  Future<void> onPlatformViewCreated(id) async {
    if (widget.onPlatformViewCreated == null) {
      return;
    }
    widget.onPlatformViewCreated(new PlatformMapController.init(id));
  }
}

class PlatformMapController {

  MethodChannel _methodChannel;

  PlatformMapController.init(int id) {
    _methodChannel = new MethodChannel('platformMap_$id');
  }

  // TODO interaction methods go here

}