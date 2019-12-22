
import 'package:dachzeltfestival/view/feedback/feedbacl_viewmodel.dart';
import 'package:dachzeltfestival/view/markdown_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:inject/inject.dart';

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
  Widget build(BuildContext context) => MarkdownView(_feedbackViewModel.markdown);
}