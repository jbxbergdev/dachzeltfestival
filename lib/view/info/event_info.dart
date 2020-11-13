import 'package:dachzeltfestival/di/injector.dart';
import 'package:dachzeltfestival/view/info/event_info_viewmodel.dart';
import 'package:flutter/cupertino.dart';

import '../markdown_view.dart';

class EventInfo extends StatelessWidget {

  EventInfo(Key key): super(key: key);

  @override
  Widget build(BuildContext context) => MarkdownView(inject<EventInfoViewModel>().markdown);

}