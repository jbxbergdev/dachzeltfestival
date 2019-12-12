import 'package:dachzeltfestival/i18n/translations.dart';
import 'package:dachzeltfestival/model/notification/notification.dart' as notification;
import 'package:dachzeltfestival/view/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

void showNotificationDialog(notification.Notification notification, BuildContext context)  {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (buildContext) {
      return AlertDialog(
        title: Text(notification.title),
        content: Text(notification.message),
        actions: <Widget>[
          FlatButton(
            child: Text(context.translations[AppString.dismiss]),
            onPressed: () => Navigator.of(context).pop(),
          ),
          notification.url != null ?
          FlatButton(
            color: colorScheme.primary,
            child: Text(
              context.translations[AppString.notificationDialogOpenLink],
              style: TextStyle(
                color: colorScheme.background,
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