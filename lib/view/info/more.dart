import 'package:dachzeltfestival/view/feedback/feedback.dart';
import 'package:dachzeltfestival/view/legal/legal.dart';
import 'package:dachzeltfestival/view/notification/notification_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inject/inject.dart';
import 'package:dachzeltfestival/i18n/translations.dart';

import '../routes.dart';

@provide
class MoreBuilder {

  final NotificationListBuilder _notificationListBuilder;
  final LegalBuilder _legalBuilder;
  final FeedbackBuilder _feedbackBuilder;

  MoreBuilder(this._notificationListBuilder, this._legalBuilder, this._feedbackBuilder);

  More build(Key key) => More(key, _notificationListBuilder, this._legalBuilder, this._feedbackBuilder);
}

class More extends StatelessWidget {

  final NotificationListBuilder _notificationListBuilder;
  final LegalBuilder _legalBuilder;
  final FeedbackBuilder _feedbackBuilder;

  More(Key key, this._notificationListBuilder, this._legalBuilder, this._feedbackBuilder): super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.background,
      child: Stack(
        children: <Widget>[
           Container(
             child: Align(
               alignment: Alignment.bottomCenter,
               child: Padding(
                 padding: const EdgeInsets.all(16.0),
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.end,
                   children: <Widget>[
                     Text(
                       "Powered by",
                       style: TextStyle(
                         color: theme.colorScheme.onPrimary.withOpacity(0.6),
                       ),
                     ),
                     Text(
                       "Johannes Bolz Softwareentwicklung",
                       style: TextStyle(
                         color: theme.colorScheme.primary,
                       ),
                     ),
                   ],
                 ),
               ),
             ),
           ),
          ListView.separated(
          itemCount: 5,
          separatorBuilder: (context, index) => Container(
            color: theme.colorScheme.background,
            child: Divider(color: theme.colorScheme.onPrimary,),
          ),
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: _buildListItem(context, Icons.notifications_none, AppString.notificationListTitle,
                          () => _notificationListBuilder.build(PageStorageKey('NotificationList'))),
                );
              case 1:
                return _buildListItem(context, Icons.info_outline, AppString.eventInfo,
                        () => Text("TODO"));
              case 2:
                return _buildListItem(context, Icons.send, AppString.feedback,
                        () => _feedbackBuilder.build(PageStorageKey('Feedback')));
              case 3:
                return _buildListItem(context, Icons.subject, AppString.legal,
                        () => _legalBuilder.build(PageStorageKey('Legal')));
              case 4:
                return Container();
              default:
                return Container();
            }
          },
        ),
      ]
      ),
    );
  }

  Widget _buildListItem(BuildContext context, IconData icon, AppString title, Widget builder()) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: ListTile(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Icon(icon),
        ),
        title: Text(context.translations[title]),
        onTap: () => Navigator.of(context).push(
            SlideInRoute(
                page: Scaffold(
                  appBar: AppBar(
                    title: Text(context.translations[title]),
                  ),
                  body: builder(),
                )
            )),
      ),
    );
  }

}