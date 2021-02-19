import 'package:dachzeltfestival/i18n/translations.dart';
import 'package:dachzeltfestival/model/notification/notification.dart' as notification;
import 'package:dachzeltfestival/view/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

void showNotificationDialog(notification.Notification notification, BuildContext context)  {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (buildContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))),
        title: Text(
          notification.title,
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w300,
          ),
        ),
        content: Text(
          notification.message,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w300,
            )
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(context.translations[AppString.dismiss]),
            onPressed: () => Navigator.of(context).pop(),
          ),
          notification.url != null ?
          FlatButton(
            color: Theme.of(context).colorScheme.primary,
            child: Text(
              notification.linkText?.isNotEmpty == true ? notification.linkText.toUpperCase() : context.translations[AppString.dialogOpenLink],
              style: TextStyle(
                color: Theme.of(context).colorScheme.background,
              ),
            ),
            onPressed: () {
              launch(notification.url);
              Navigator.of(context).pop();
            },
          ) : Container(),
        ],
      );
    }
  );
}