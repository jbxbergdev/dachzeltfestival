
import 'package:dachzeltfestival/di/injector.dart';
import 'package:dachzeltfestival/view/feed/feed_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Feed extends StatelessWidget {

  Feed(Key key) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = inject<FeedViewModel>();
    return StreamBuilder<String>(
      stream: viewModel.feedHtml,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        String url = Uri.dataFromString(snapshot.data, mimeType: 'text/html').toString();
        return WebView(
          key: PageStorageKey(url),
          initialUrl: url,
          javascriptMode: JavascriptMode.unrestricted,
          navigationDelegate: (navigationRequest) {
            if (navigationRequest.url == url) {
              return NavigationDecision.navigate;
            }
            launch(navigationRequest.url);
            return NavigationDecision.prevent;
          },
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[ // Workaround: https://github.com/flutter/flutter/issues/27180#issuecomment-513339411
            Factory(() => EagerGestureRecognizer()),
          ].toSet(),
        );
      },
    );
  }
}