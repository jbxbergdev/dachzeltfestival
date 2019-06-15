import 'package:flutter/material.dart';
import 'package:inject/inject.dart';
import 'schedule_viewmodel.dart';
import 'package:dachzeltfestival/model/schedule/schedule_item.dart';

typedef Provider<T> = T Function();

@provide
class ScheduleBuilder {

  final Provider<ScheduleViewModel> _vmProvider;

  ScheduleBuilder(this._vmProvider);

  Schedule build(Key key) => Schedule(key, _vmProvider());
}

class Schedule extends StatelessWidget {

  final ScheduleViewModel _scheduleViewModel;

  Schedule(Key key, this._scheduleViewModel) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ScheduleItem>>(
      stream: _scheduleViewModel.observeSchedule(),
      builder: (BuildContext context, AsyncSnapshot<List<ScheduleItem>> asyncSnapshot) {
        if (asyncSnapshot.hasData) {
          return ListView(
            children: asyncSnapshot.data.map((scheduleItem) {
              return ListTile(
                title: Text(scheduleItem.start.toLocal().toString() + " - " + scheduleItem.finish.toLocal().toString()),
                subtitle: Text(scheduleItem.title),
              );
            }).toList(),
          );
        } else if (asyncSnapshot.error != null) {
          return Text(asyncSnapshot.error.toString());
        } else {
          return Text("loading ...");
        }
      },
    );
  }

}