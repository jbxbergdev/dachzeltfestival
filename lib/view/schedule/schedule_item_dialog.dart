import 'package:dachzeltfestival/di/injector.dart';
import 'package:dachzeltfestival/model/schedule/schedule_item.dart';
import 'package:dachzeltfestival/util/utils.dart';
import 'package:dachzeltfestival/view/place_selection_interactor.dart';
import 'package:dachzeltfestival/view/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dachzeltfestival/i18n/translations.dart';
import 'package:url_launcher/url_launcher.dart';

void showScheduleItemDialog(BuildContext context, ScheduleItem scheduleItem, PlaceSelectionInteractor placeSelectionInteractor) {
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (buildContext)
  {
    final appTheme = inject<AppTheme>();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
            Padding(
            padding: EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                scheduleItem.title,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w300
                ),
              ),
            ),
          ),
          isNotNullOrEmpty(scheduleItem.speaker) ? Padding(
            padding: EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                scheduleItem.speaker.toUpperCase(),
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey[500]
                ),
              ),
            ),
          ) : Container(),
          Padding(
            padding: EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _formatTimestamps(scheduleItem.start, scheduleItem.finish, context),
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey[500]
                ),
              ),
            ),
          ),
          isNotNullOrEmpty(scheduleItem.venue) ? InkWell(
            onTap: () {
              Navigator.of(context).pop();
              placeSelectionInteractor.selectedPlaceId.add(scheduleItem.placeId);
            },
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Icon(
                        Icons.place,
                        size: 16.0,
                        color: scheduleItem.color != null ? hexToColor(scheduleItem.color) : appTheme.current.colorScheme.onBackground,
                      ),
                    ),
                    Container(
                      child: Expanded(
                        child: Text(
                          scheduleItem.venue,
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w300,
                              color: scheduleItem.color != null ? hexToColor(scheduleItem.color) : appTheme.current.colorScheme.onBackground,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ): Container(),
          isNotNullOrEmpty(scheduleItem.abstract) ? Flexible(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
              child: SingleChildScrollView(
                child: SelectableText(
                  scheduleItem.abstract,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
          ) : Container(),
          ButtonBar(
            children: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.translations[AppString.dismiss]),
              ),
              scheduleItem.url != null ? FlatButton(
                color: Theme.of(context).colorScheme.primary,
                child: Text(
                  scheduleItem.linkText?.isNotEmpty == true ? scheduleItem.linkText.toUpperCase() : context.translations[AppString.dialogOpenLink],
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.background,
                  ),
                ),
                onPressed: () {
                  launch(scheduleItem.url);
                },
              ) : Container(),
            ],
          )
        ],
      ),
    );
  });
}

String _formatTimestamps(DateTime start, DateTime end, BuildContext context) {
  String language = Localizations.localeOf(context).supportedOrDefaultLangCode;
  DateFormat from = DateFormat.EEEE(language).add_jm();
  DateFormat to = DateFormat.jm(language);
  return "${from.format(start)} - ${to.format(end)}";
}