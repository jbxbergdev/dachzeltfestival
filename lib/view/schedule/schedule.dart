import 'package:dachzeltfestival/i18n/translations.dart';
import 'package:dachzeltfestival/util/utils.dart';
import 'package:dachzeltfestival/view/schedule/schedule_item_dialog.dart';
import 'package:dachzeltfestival/view/theme.dart';
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
        if (asyncSnapshot.hasData && asyncSnapshot.data.isNotEmpty) {
          return CustomScrollView(
            slivers: _buildListContent(asyncSnapshot.data, context),
          );
        } else if (asyncSnapshot.error != null) {
          return Text(asyncSnapshot.error.toString());
        } else {
          return Center(child: Text(context.translations[AppString.loading]));
        }
      },
    );
  }

  List<Widget> _buildListContent(Map<DateTime, List<ScheduleItem>> itemMap, BuildContext context) {
    List<Widget> listContent = List();

    if (itemMap.isEmpty) {
      return listContent;
    }

    ThemeData theme = Theme.of(context);
    String language = Localizations.localeOf(context).languageCode;
    DateFormat hourMinute = DateFormat.jm(language);
    DateFormat weekday = DateFormat.EEEE(language);

    int lastDay = -1;

    itemMap.keys.forEach((start) {
      if (lastDay != start.day) {
        listContent.add(SliverStickyHeader(
          header: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Text(
                weekday.format(start),
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w300,
                ),),
            ),
          ),
        ));
      }
      lastDay = start.day;
      listContent.add(SliverStickyHeader(
        overlapsContent: true,
        header: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
                hourMinute.format(start),
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                ),),
          ),
        ),
        sliver: SliverPadding(
          padding: EdgeInsets.only(
            left: 56.0,
            top: 1.0,
          ),
          sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    ScheduleItem scheduleItem = itemMap[start][index];
                    String speaker = scheduleItem.speaker;
                    if (speaker.isNotEmpty) { speaker = speaker + ": "; }
                    return InkWell(
                      onTap: () => showScheduleItemDialog(context, scheduleItem, _scheduleViewModel.placeSelectionInteractor),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                  scheduleItem.title,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                            ),
                            Visibility(
                              visible: scheduleItem.speaker != null && scheduleItem.speaker.isNotEmpty,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      scheduleItem.speaker ?? "",
                                      style: TextStyle(
                                        color: Colors.grey[600]
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: scheduleItem.venue != null
                                            ? Icon(Icons.place, size: 12.0, color: scheduleItem.color != null ? hexToColor(scheduleItem.color) : Colors.grey[600],)
                                            : Container(),
                                      ),
                                      Text(
                                        scheduleItem.venue ?? "",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "${context.translations[AppString.scheduleUntil]} ${hourMinute.format(scheduleItem.finish)}",
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.grey[500]
                                    )
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                childCount: itemMap[start].length,
              ),
          ),
        ),
      ));
    });
    return listContent;
  }

  Future<Map<DateTime, List<ScheduleItem>>> _buildScheduleMap(List<ScheduleItem> itemList) async {
    Set<String> venues = Set();
    Map<DateTime, List<ScheduleItem>> scheduleMap = LinkedHashMap(); // maintains key insertion order
    itemList.forEach((scheduleItem) {
      if (scheduleMap[scheduleItem.start] == null) {
        scheduleMap[scheduleItem.start] = List();
      }
      scheduleMap[scheduleItem.start].add(scheduleItem);
      venues.add(scheduleItem.venue);
    });
    return scheduleMap;
  }

}