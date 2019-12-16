import 'package:dachzeltfestival/view/notification/notification_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inject/inject.dart';

import '../routes.dart';

@provide
class InfoBuilder {

  final NotificationListBuilder _notificationListBuilder;

  InfoBuilder(this._notificationListBuilder);

  Info build(Key key) => Info(key, _notificationListBuilder);
}

class Info extends StatelessWidget {

  final NotificationListBuilder _notificationListBuilder;

  Info(Key key, this._notificationListBuilder): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FlatButton(
        child: Text("Hit me!"),
        onPressed: () => Navigator.of(context).push(SlideInRoute(page: _notificationListBuilder.build(PageStorageKey('NotificationList'))),
        ),
      ),
    );
  }
}