import 'package:flutter/cupertino.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';

class MarkdownView extends StatelessWidget {

  final Stream<String> _stream;

  MarkdownView(this._stream);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: StreamBuilder(
        stream: _stream,
        builder: (buildContext, asyncSnapshot) {
          if (asyncSnapshot.hasData) {
            return Markdown(
              data: asyncSnapshot.data,
              onTapLink: (text, href, title) => launch(href),
            );
          }
          return Container();
        },
      ),
    );
  }
}