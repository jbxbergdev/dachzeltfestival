
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
            return Container(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  notification.Notification item = snapshot.data[index];
                  double paddingAbove = index == 0 ? 12.0 : 4.0;
                  double paddingBelow = index == snapshot.data.length - 1 ? 12.0 : 4.0;
                  return Padding(
                    padding: EdgeInsets.only(left: 8.0, top: paddingAbove, right: 8.0, bottom: paddingBelow),
                    child: Card(
                      elevation: 4.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      item.title,
                                      style: TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                      item.message,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w300,
                                      )
                                  ),
                                ),
                              ],
                            ),
                          ),
                         item.url != null ? ButtonBar(
                            children: <Widget>[FlatButton(
                              child: Text(context.translations[AppString.notificationDialogOpenLink]),
                              onPressed: () => launch(item.url),
                            )],
                          ) : Container(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return Container();
        },
      ),
    );
  }

}