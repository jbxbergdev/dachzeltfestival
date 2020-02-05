import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:dachzeltfestival/i18n/translations.dart';
import 'package:dachzeltfestival/util/utils.dart';
import 'package:dachzeltfestival/view/schedule/schedule_item_dialog.dart';
import 'package:flutter/material.dart';
import 'package:inject/inject.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
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

class Schedule extends StatefulWidget {

  final ScheduleViewModel _scheduleViewModel;

  Schedule(Key key, this._scheduleViewModel) : super(key: key);

  @override
  _ScheduleState createState() => _ScheduleState();

}

class _ScheduleState extends State<Schedule> {

  final BehaviorSubject<DateTime> _currentTime = BehaviorSubject();
  final CompositeSubscription _compositeSubscription = CompositeSubscription();
  final BehaviorSubject<int> _selectedPageIndex = BehaviorSubject.seeded(0);
  List<Widget> _tabList;
  bool _firstLayout = true;

  @override
  void initState() {
    super.initState();
    _compositeSubscription.add(
        widget._scheduleViewModel.currentTimeMinuteInterval().listen((time) => _currentTime.add(time)));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<DateTime, Map<DateTime, _ItemsWithEndTime>>>(
      stream: widget._scheduleViewModel.observeSchedule().asyncMap(_buildScheduleMaps),
      builder: (BuildContext context, AsyncSnapshot<Map<DateTime, Map<DateTime, _ItemsWithEndTime>>> asyncSnapshot) {
        if (asyncSnapshot.hasData && asyncSnapshot.data.isNotEmpty) {
          return _buildTabLayout(asyncSnapshot.data, context);
        } else if (asyncSnapshot.error != null) {
          return Text(asyncSnapshot.error.toString());
        } else {
          return Center(child: Text(context.translations[AppString.loading]));
        }
      },
    );
  }

  Widget _buildTabLayout(Map<DateTime, Map<DateTime, _ItemsWithEndTime>> itemMap, BuildContext context) {
    _tabList = itemMap.keys.map((date) {
      return Container(
        color: Theme.of(context).colorScheme.background,
        child: CustomScrollView(
          slivers: _buildListContent(itemMap[date]),
        ),
      );
    }).toList();
    bool firstLayout = _firstLayout;
    _firstLayout = false;
    return SizedBox.expand(
      child: StreamBuilder<DateTime>(
        stream: _currentTime.first.asStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          int initialIndex = 0;
          if (firstLayout) {
            initialIndex = _dateSelectionIndex(snapshot.data.dayMonthYear(), itemMap.keys.toList());
            _selectedPageIndex.add(initialIndex);
          }
          // Because flutter_sticky_headers doesn't work well with TabBarView, we use a 'hacked' tab layout that doesn't use TabBarView,
          // but an IndexedStack instead.
          return DefaultTabController(
            length: itemMap.length,
            initialIndex: initialIndex,
            child: Column(
              children: <Widget>[
                _buildTabSelector(itemMap, context),
                _buildTabs(),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildTabSelector(Map<DateTime, Map<DateTime, _ItemsWithEndTime>> itemMap, BuildContext context) {
    ThemeData theme = Theme.of(context);
    String language = Localizations.localeOf(context).languageCode;
    DateFormat shortDate = DateFormat.Md(language);
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        color: theme.colorScheme.background,
        height: 40,
        child: Align(
          alignment: Alignment.center,
          child: TabBar(
            onTap: (index) => _selectedPageIndex.add(index),
            isScrollable: true,
            indicator: new BubbleTabIndicator(
              indicatorHeight: 24.0,
              indicatorColor: theme.primaryColor.withOpacity(0.5),
              tabBarIndicatorSize: TabBarIndicatorSize.tab,
            ),
            tabs: itemMap.keys.map((date) => Tab(
                child: StreamBuilder<Tuple2<int, DateTime>>(
                    stream: Rx.combineLatest2(_selectedPageIndex, _currentTime, (index, time) => Tuple2(index, time)),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container();
                      }
                      bool isSelected = snapshot.data.item1 == itemMap.keys.toList().indexOf(date);
                      bool isDayPassed = _isDayPassed(snapshot.data.item2, date);
                      return Text(
                        shortDate.format(date),
                        style: TextStyle(
                          color: isSelected ? theme.colorScheme.background : (isDayPassed ? Colors.grey[400] : theme.colorScheme.onPrimary),
                        ),
                      );
                    }
                )),
            ).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Expanded(
      child: Stack(
        children: <Widget>[
          StreamBuilder<int>(
              stream: _selectedPageIndex,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }
                return IndexedStack(
                  index: snapshot.data,
                  children: _tabList,
                );
              }
          ),
          Container(
            height: 2,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[Colors.white, Colors.white.withOpacity(0.0)],
                )
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _buildListContent(Map<DateTime, _ItemsWithEndTime> itemMap) {
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
              padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
              child: StreamBuilder<bool>(
                stream: _currentTime.map((dateTime) => _isDayPassed(dateTime, start)),
                builder: (context, snapshot) {
                  bool dayIsPassed = snapshot.data == true;
                  return Text(
                    weekday.format(start),
                    style: TextStyle(
                      color: dayIsPassed ? Colors.grey[400] : theme.primaryColor,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w300,
                    ),);
                }
              ),
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
            child: StreamBuilder<DateTime>(
              stream: _currentTime,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }
                return Container(
                  width: 48,
                  child: Text(
                      hourMinute.format(start),
                      style: TextStyle(
                        color: start.isAfter(snapshot.data)
                            ? theme.primaryColor
                            : (itemMap[start].allItemsFinished(snapshot.data) ? Colors.grey[400] : theme.primaryColor.withOpacity(0.4)),
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                      ),),
                );
              }
            ),
          ),
        ),
        sliver: SliverPadding(
          padding: EdgeInsets.only(
            left: 56.0,
          ),
          sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    ScheduleItem scheduleItem = itemMap[start].scheduleItems[index];
                    String speaker = scheduleItem.speaker;
                    if (speaker.isNotEmpty) { speaker = speaker + ": "; }
                    return StreamBuilder<DateTime>(
                      stream: _currentTime,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Container();
                        }
                        bool isFinished = snapshot.data.isAfter(scheduleItem.finish);
                        return Opacity(
                          opacity: isFinished ? 0.4 : 1.0,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: InkWell(
                              onTap: () => showScheduleItemDialog(context, scheduleItem, widget._scheduleViewModel.placeSelectionInteractor),
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
                                    IntrinsicHeight(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Flexible(
                                            flex: 1,
                                            child: IntrinsicWidth(
                                              child: Column(
                                                children: <Widget>[
                                                  Visibility(
                                                    visible: scheduleItem.speaker != null && scheduleItem.speaker.isNotEmpty,
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(top: 8.0),
                                                      child: Align(
                                                        alignment: Alignment.bottomLeft,
                                                        child: Text(
                                                          scheduleItem.speaker ?? "",
                                                          style: TextStyle(
                                                              color: Colors.grey[600]
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible: scheduleItem.venue?.isNotEmpty == true,
                                                    child: Padding(
                                                      padding: EdgeInsets.only(top: 8.0),
                                                      child: Row(
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
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            flex: 0,
                                            child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: Text(
                                                  "${context.translations[AppString.scheduleUntil]} ${hourMinute.format(scheduleItem.finish)}",
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                    color: Colors.grey[500],
                                                  )
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    );
                  },
                childCount: itemMap[start].scheduleItems.length,
              ),
          ),
        ),
      ));
    });
    return listContent;
  }

  /// Mapping start day -> start time -> schedule items
  Future<Map<DateTime, Map<DateTime, _ItemsWithEndTime>>> _buildScheduleMaps(List<ScheduleItem> itemList) async {

    Map<DateTime, Map<DateTime, List<ScheduleItem>>> datesMap = LinkedHashMap();

    itemList.forEach((scheduleItem) {
      DateTime day = scheduleItem.start.dayMonthYear();
      if (datesMap[day] == null) {
        datesMap[day] = LinkedHashMap();
      }
      if (datesMap[day][scheduleItem.start] == null) {
        datesMap[day][scheduleItem.start] = List();
      }
      datesMap[day][scheduleItem.start].add(scheduleItem);
    });

    return datesMap.map((day, dayMap) =>
        MapEntry(day, dayMap.map((start, scheduleItems) =>
            MapEntry(start, _ItemsWithEndTime(scheduleItems)))));
  }

  bool _isDayPassed(DateTime now, DateTime toCheck) => toCheck.year < now.year || toCheck.month < now.month || toCheck.day < now.day;

  int _dateSelectionIndex(DateTime today, List<DateTime> dates) {
    // return current date index if it is within the date range
    if (dates.contains(today)) {
      return dates.indexOf(today);
    }
    // otherwise, return first index
    return 0;
  }

  @override
  void dispose() {
    _compositeSubscription.dispose();
    super.dispose();
  }
}

class _ItemsWithEndTime {
  final List<ScheduleItem> scheduleItems;
  DateTime _finish = DateTime.fromMillisecondsSinceEpoch(0);

  _ItemsWithEndTime(this.scheduleItems) {
    scheduleItems.forEach((scheduleItem) {
      if (scheduleItem.finish.isAfter(_finish)) {
        _finish = scheduleItem.finish;
      }
    });
  }

  DateTime get finish => _finish;

  bool allItemsFinished(DateTime now) => now.isAfter(_finish);
}

extension on DateTime {
  DateTime dayMonthYear() => DateTime(year, month, day);
}
