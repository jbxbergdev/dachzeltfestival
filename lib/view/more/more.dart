import 'package:dachzeltfestival/view/charity/charity.dart';
import 'package:dachzeltfestival/view/feedback/feedback.dart';
import 'package:dachzeltfestival/view/info/event_info.dart';
import 'package:dachzeltfestival/view/legal/legal.dart';
import 'package:dachzeltfestival/view/notification/notification_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inject/inject.dart';
import 'package:dachzeltfestival/i18n/translations.dart';

import '../routes.dart';

@provide
class MoreBuilder {

  final CharityBuilder _charityBuilder;
  final LegalBuilder _legalBuilder;
  final FeedbackBuilder _feedbackBuilder;
  final EventInfoBuilder _eventInfoBuilder;

  MoreBuilder(this._charityBuilder, this._legalBuilder, this._feedbackBuilder, this._eventInfoBuilder);

  More build(Key key) => More(key, _charityBuilder, this._legalBuilder, this._feedbackBuilder, this._eventInfoBuilder);
}

class More extends StatelessWidget {

  final CharityBuilder _charityBuilder;
  final LegalBuilder _legalBuilder;
  final FeedbackBuilder _feedbackBuilder;
  final EventInfoBuilder _eventInfoBuilder;

  More(Key key, this._charityBuilder, this._legalBuilder, this._feedbackBuilder, this._eventInfoBuilder): super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.background,
      child: ListView.separated(
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
                child: _buildListItem(context, Icons.favorite_border, AppString.navItemDonate,
                        () => _charityBuilder.build(PageStorageKey('Charity'))),
              );
            case 1:
              return _buildListItem(context, Icons.info_outline, AppString.eventInfo,
                      () => _eventInfoBuilder.build(PageStorageKey('EventInfo')));
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