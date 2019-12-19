
import 'package:dachzeltfestival/view/notification/notification_list_viewmodel.dart';
import 'package:dachzeltfestival/i18n/translations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:inject/inject.dart';
import 'package:dachzeltfestival/model/notification/notification.dart' as notification;
import 'package:url_launcher/url_launcher.dart';

typedef Provider<T> = T Function();

@provide
class NotificationListBuilder {
   final Provider<NotificationListViewModel> _vmProvider;

   NotificationListBuilder(this._vmProvider);

   NotificationList build(Key key) => NotificationList(key, _vmProvider());
}

class NotificationList extends StatelessWidget {

  final NotificationListViewModel _viewModel;

  NotificationList(Key key, this._viewModel): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.translations[AppString.notificationListTitle]),
      ),
      body: StreamBuilder<List<notification.Notification>>(
        stream: _viewModel.notifications(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                notification.Notification item = snapshot.data[index];
                return Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        title: Text(item.title),
                        subtitle: Text(item.message),
                      ),
                     item.url != null ? ButtonBar(
                        children: <Widget>[FlatButton(
                          child: Text(context.translations[AppString.notificationDialogOpenLink]),
                          onPressed: () => launch(item.url),
                        )],
                      ) : Container(),
                    ],
                  ),
                );
              },
            );
          }
          return Container();
        },
      ),
    );
  }

}