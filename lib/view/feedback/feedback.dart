
import 'package:dachzeltfestival/view/feedback/feedbacl_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:inject/inject.dart';
import 'package:url_launcher/url_launcher.dart';

typedef Provider<T> = T Function();

@provide
class FeedbackBuilder {
  final Provider<FeedbackViewModel> _vmProvider;

  FeedbackBuilder(this._vmProvider);

  Legal build(Key key) => Legal(_vmProvider());
}

class Legal extends StatelessWidget {

  final FeedbackViewModel _feedbackViewModel;

  Legal(this._feedbackViewModel);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: StreamBuilder(
        stream: _feedbackViewModel.markdown,
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