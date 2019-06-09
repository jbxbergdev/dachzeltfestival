
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rubber/rubber.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TestPageState();
  }

}

class _TestPageState extends State<TestPage> with SingleTickerProviderStateMixin {

  RubberAnimationController _controller;

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _controller = RubberAnimationController(
        vsync: this,
        halfBoundValue: AnimationControllerValue(percentage: 0.5),
        lowerBoundValue: AnimationControllerValue(percentage: 0.0),
        duration: Duration(milliseconds: 200),
        initialValue: 0.5
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
//    return GoogleMap(initialCameraPosition: CameraPosition(target: LatLng(52.5, 13.5)));
  return Container(
    child: RubberBottomSheet(
      scrollController: _scrollController,
      lowerLayer: _getLowerLayer(),
      header: Container(
        color: Colors.yellow,
      ),
      headerHeight: 60,
      upperLayer: _getUpperLayer(),
      animationController: _controller,
    ),
  );
  }

  Widget _getLowerLayer() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.cyan[100]
      ),
    );
  }

  Widget _getUpperLayer() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.cyan
      ),
      child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          controller: _scrollController,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(title: Text("Item $index"));
          },
          itemCount: 100
      ),
    );
  }
}