import 'package:dachzeltfestival/i18n/translations.dart';
import 'package:dachzeltfestival/model/notification/notification.dart' as notification;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

void showNotificationDialog(notification.Notification notification, BuildContext context)  {
  Translations translations = Translations.of(context);
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (buildContext) {
      return AlertDialog(
        title: Text(notification.title),
        content: Text(notification.message),
        actions: <Widget>[
          notification.url != null ?
          FlatButton(
              child: Text(translations[AppString.notificationDialogOpenLink]),
              onPressed: () {
                launch(notification.url);
                Navigator.of(context).pop();
                },
            ) : Container(),
          FlatButton(
            child: Text(translations[AppString.ok]),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      );
    }
  );
}