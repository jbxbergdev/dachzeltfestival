import 'package:flutter/material.dart';
import 'package:inject/inject.dart';
import 'schedule_viewmodel.dart';
import 'package:dachzeltfestival/model/schedule/schedule_item.dart';
import 'package:intl/intl.dart';

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
            children: asyncSnapshot.data
                .map((scheduleItem) {
                  DateFormat weekdayTime = DateFormat.EEEE('de').add_Hm();
                  DateFormat hourMinute = DateFormat.Hm('de');
                  String speaker = scheduleItem.speaker;
                  if (speaker.isNotEmpty) { speaker = speaker + ": ";}
              return ListTile(
                title: Text(speaker + scheduleItem.title),
                subtitle: Text(weekdayTime.format(scheduleItem.start) + " - " + hourMinute.format(scheduleItem.finish) + ", " + scheduleItem.venue),
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