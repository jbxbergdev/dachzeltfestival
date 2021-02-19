
import 'package:dachzeltfestival/di/injector.dart';
import 'package:dachzeltfestival/view/notification/notification_list_viewmodel.dart';
import 'package:dachzeltfestival/i18n/translations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:dachzeltfestival/model/notification/notification.dart' as notification;
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class NotificationList extends StatelessWidget {

  NotificationList(Key key): super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = inject<NotificationListViewModel>();
    return StreamBuilder<List<notification.Notification>>(
        stream: viewModel.notifications().sortPersistentFirst(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            ThemeData theme = Theme.of(context);
            return Container(
              child: ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  notification.Notification item = snapshot.data[index];
                  double paddingAbove = index == 0 ? 12.0 : 4.0;
                  double paddingBelow = index == snapshot.data.length - 1 ? 12.0 : 4.0;
                  return Padding(
                    padding: EdgeInsets.only(left: 8.0, top: paddingAbove, right: 8.0, bottom: paddingBelow),
                    child: Card(
                      elevation: 2.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        child: Container(
                          color: item.persistent ? theme.colorScheme.primary.withOpacity(0.15) : theme.cardColor,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
                                  child: Column(
                                    children: <Widget>[
                                      item.persistent ? Container() : Padding(
                                        padding: EdgeInsets.only(bottom: 12.0),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            _formatTimestamp(item.timestamp, context),
                                            style: /*TextStyle(
                                              color: Colors.grey[600],
                                            )*/ theme.textTheme.caption,
                                          ),
                                        ),
                                      ),
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
                                  children: <Widget>[
                                    FlatButton(
                                      child: Text(
                                          item.linkText?.isNotEmpty == true ? item.linkText.toUpperCase() : context.translations[AppString.dialogOpenLink]
                                      ),
                                      onPressed: () => launch(item.url),
                                      textColor: item.persistent ? theme.colorScheme.primary : theme.colorScheme.primary,
                                  )],
                                ) : Container(height: 24.0,),
                              ],
                            ),
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

  String _formatTimestamp(DateTime timestamp, BuildContext context) {
    DateTime now = DateTime.now();
    DateTime startOfToday = DateTime(now.year, now.month, now.day);
    DateTime startOfTimestampDay = DateTime(timestamp.year, timestamp.month, timestamp.day);
    int deltaDays = startOfToday.difference(startOfTimestampDay).inDays;

    String language = Localizations.localeOf(context).supportedOrDefaultLangCode;

    switch (deltaDays) {
      case 0:
        return "${context.translations[AppString.today]} ${DateFormat.jm(language).format(timestamp)}".toUpperCase();
      case 1:
        return "${context.translations[AppString.yesterday]} ${DateFormat.jm(language).format(timestamp)}".toUpperCase();
      default:
        return DateFormat.Md(language).add_jm().format(timestamp).toUpperCase();
    }
  }

}

extension on Stream<List<notification.Notification>> {
  Stream<List<notification.Notification>> sortPersistentFirst() {
    return this.asyncMap((notifications) => notifications..sort((left, right) {
      if (left.persistent != right.persistent) {
        return left.persistent ? -1 : 1;
      }
      return right.timestamp.compareTo(left.timestamp);
    }));
  }
}
