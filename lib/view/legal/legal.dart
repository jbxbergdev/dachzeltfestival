import 'dart:convert';

import 'package:dachzeltfestival/view/legal/legal_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:inject/inject.dart';
import 'package:url_launcher/url_launcher.dart';

typedef Provider<T> = T Function();

@provide
class LegalBuilder {
  final Provider<LegalViewModel> _vmProvider;

  LegalBuilder(this._vmProvider);

  Legal build(Key key) => Legal(_vmProvider());
}

class Legal extends StatelessWidget {

  final LegalViewModel _legalViewModel;

  Legal(this._legalViewModel);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: StreamBuilder(
        stream: _legalViewModel.legalMarkdown(),
        builder: (buildContext, asyncSnapshot) {
          if (asyncSnapshot.hasData) {
            return Markdown(
              data: asyncSnapshot.data,
              onTapLink: (url) => launch(url),
            );
          }
          return Container();
        },
      ),
    );
  }

}