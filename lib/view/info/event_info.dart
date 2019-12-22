import 'package:dachzeltfestival/view/info/event_info_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:inject/inject.dart';

import '../markdown_view.dart';

typedef Provider<T> = T Function();

@provide
class EventInfoBuilder {
  final Provider<EventInfoViewModel> _vmProvider;

  EventInfoBuilder(this._vmProvider);

  EventInfo build(Key key) => EventInfo(_vmProvider());
}

class EventInfo extends StatelessWidget {

  final EventInfoViewModel _eventInfoViewModel;

  EventInfo(this._eventInfoViewModel);

  @override
  Widget build(BuildContext context) => MarkdownView(_eventInfoViewModel.markdown);

}