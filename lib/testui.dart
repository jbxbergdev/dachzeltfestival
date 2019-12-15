import 'package:dachzeltfestival/view/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TestUi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FlatButton(
        child: Text("Hit me!"),
        onPressed: () => Navigator.of(context).push(SlideInRoute(page: TestNewRoute()),
        ),
      ),
    );
  }
}

class TestNewRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Route"),
      ),
      body: Container(
        child: Text("Test"),
      ),
    );
  }
  
}