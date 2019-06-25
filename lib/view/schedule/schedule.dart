import 'package:flutter/material.dart';
import 'package:inject/inject.dart';
import 'schedule_viewmodel.dart';
import 'package:dachzeltfestival/model/schedule/schedule_item.dart';
import 'package:intl/intl.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'dart:collection';

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
    return StreamBuilder<Map<DateTime, List<ScheduleItem>>>(
      stream: _scheduleViewModel.observeSchedule().asyncMap(_buildScheduleMap),
      builder: (BuildContext context, AsyncSnapshot<Map<DateTime, List<ScheduleItem>>> asyncSnapshot) {
        if (asyncSnapshot.hasData) {
//          return ListView(
//            children: asyncSnapshot.data
//                .map((scheduleItem) {
//                  DateFormat weekdayTime = DateFormat.EEEE('de').add_Hm();
//                  DateFormat hourMinute = DateFormat.Hm('de');
//                  String speaker = scheduleItem.speaker;
//                  if (speaker.isNotEmpty) { speaker = speaker + ": ";}
//              return ListTile(
//                title: Text(speaker + scheduleItem.title),
//                subtitle: Text(weekdayTime.format(scheduleItem.start) + " - " + hourMinute.format(scheduleItem.finish) + ", " + scheduleItem.venue),
//              );
//            }).toList(),
//          );
          return CustomScrollView(
            slivers: _buildListContent(asyncSnapshot.data),
          );
        } else if (asyncSnapshot.error != null) {
          return Text(asyncSnapshot.error.toString());
        } else {
          return Text("loading ...");
        }
      },
    );
  }

  List<Widget> _buildListContent(Map<DateTime, List<ScheduleItem>> itemMap) {
    List<Widget> listContent = List();

    if (itemMap.isEmpty) {
      return listContent;
    }

    DateFormat weekdayTime = DateFormat.EEEE('de').add_Hm();
    DateFormat hourMinute = DateFormat.Hm('de');

    itemMap.keys.forEach((start) {
      listContent.add(SliverStickyHeader(
        overlapsContent: true,
        header: Text(hourMinute.format(start)),
        sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                (context, index) {
                  ScheduleItem scheduleItem = itemMap[start][index];
                  String speaker = scheduleItem.speaker;
                  if (speaker.isNotEmpty) { speaker = speaker + ": "; }
                  return ListTile(
                    title: Text("$speaker${scheduleItem.title}"),
                    subtitle: Text(scheduleItem.venue),
                  );
                },
              childCount: itemMap[start].length,
            ),
        ),
      ));
    });
    return listContent;
  }

  Future<Map<DateTime, List<ScheduleItem>>> _buildScheduleMap(List<ScheduleItem> itemList) async {
    Map<DateTime, List<ScheduleItem>> scheduleMap = LinkedHashMap(); // maintains key insertion order
    itemList.forEach((scheduleItem) {
      if (scheduleMap[scheduleItem.start] == null) {
        scheduleMap[scheduleItem.start] = List();
      }
      scheduleMap[scheduleItem.start].add(scheduleItem);
    });

    return scheduleMap;
  }

}