
import 'package:dachzeltfestival/di/injector.dart';
import 'package:dachzeltfestival/view/feedback/feedback_viewmodel.dart';
import 'package:dachzeltfestival/view/markdown_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class FeedbackWidget extends StatelessWidget {
  
  FeedbackWidget(Key key): super(key: key);
  
  @override
  Widget build(BuildContext context) => MarkdownView(inject<FeedbackViewModel>().markdown);
}