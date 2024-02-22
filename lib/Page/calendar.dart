import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:retaskd/Sheets/task_sheet.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:retaskd/data.dart';
import '../Classes/task.dart';
import '../Sheets/sheet_add_task.dart';
import '../Widgets/body.dart';
import '../theme/colors.dart';

class PageCalendar extends StatefulWidget {
  const PageCalendar({Key? key}) : super(key: key);

  @override
  PageCalendarState createState() => PageCalendarState();
}

List<Task> calendarTasks = [];

class PageCalendarState extends State<PageCalendar> {
  int firstDay = 1;
  CalendarView calendarView2 = CalendarView.schedule;

  @override
  void initState() {
    Map<String, CalendarView> views = {
      'Schedule': CalendarView.schedule,
      'Month': CalendarView.month,
      'Week': CalendarView.week,
    };
    calendarView2 = views[pf['calendarView']]!;
    Map<String, int> days = {
      'Monday': 1,
      'Sunday': 7,
      'Saturday': 6,
    };
    firstDay = days[pf['weekday']]!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16),
        child: pf['actionPosition'] != 'Top'
            ? FloatingActionButton(
                tooltip: l['Add task'],
                child: const Icon(Icons.add),
                onPressed: () {
                  showModalBottomSheet(
                    elevation: 32,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return const SheetAddTask();
                    },
                  );
                },
              )
            : null,
      ),
      floatingActionButtonLocation: pf['actionPosition'] == 'End'
          ? FloatingActionButtonLocation.endFloat
          : FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: Text(l['Calendar']),
        actions: [
          pf['actionPosition'] == 'Top'
              ? IconButton(
                  tooltip: l['Add task'],
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    showModalBottomSheet(
                      elevation: 32,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        return const SheetAddTask();
                      },
                    );
                  },
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: l['Calendar filters'],
              onPressed: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState2) {
                        return Card(
                          shadowColor: Colors.transparent,
                          margin: const EdgeInsets.all(8),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          color: Theme.of(context).bottomSheetTheme.backgroundColor,
                          child: ListView(
                            padding: const EdgeInsets.all(8),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              ListTile(
                                title: Text(
                                  l['Filters shown in calendar : '],
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              const Divider(thickness: 2),
                              ListTile(
                                onTap: () {},
                                title: SizedBox(
                                  height: 48,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return InputChip(
                                        onSelected: (value) {
                                          setState2(() {
                                            value
                                                ? tagsUnincluded2.remove(icons.keys.elementAt(index))
                                                : tagsUnincluded2.add(icons.keys.elementAt(index));
                                          });
                                          setState(() {
                                            value
                                                ? tagsUnincluded.remove(icons.keys.elementAt(index))
                                                : tagsUnincluded.add(icons.keys.elementAt(index));
                                          });
                                        },
                                        selected: !tagsUnincluded2.contains(icons.keys.elementAt(index)),
                                        label: Icon(
                                          icons.values.elementAt(index),
                                          color: tagsUnincluded2.contains(icons.keys.elementAt(index))
                                              ? Theme.of(context).primaryColor
                                              : Theme.of(context).scaffoldBackgroundColor,
                                        ),
                                      );
                                    },
                                    separatorBuilder: (BuildContext context, int index) {
                                      return const SizedBox(
                                        width: 4,
                                      );
                                    },
                                    itemCount: icons.length,
                                  ),
                                ),
                              ),
                              ListTile(
                                title: SizedBox(
                                  height: 48,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return InputChip(
                                        selected: !colorsUnincluded2.contains(lightColors.keys.elementAt(index)),
                                        label: CircleAvatar(
                                          backgroundColor: darkColors.values.elementAt(index),
                                          maxRadius: 12,
                                        ),
                                        backgroundColor: darkColors.values.elementAt(index),
                                        onSelected: (value) {
                                          setState2(() {
                                            value
                                                ? colorsUnincluded2.remove(lightColors.keys.elementAt(index))
                                                : colorsUnincluded2.add(lightColors.keys.elementAt(index));
                                          });
                                          setState(() {
                                            value
                                                ? colorsUnincluded.remove(lightColors.keys.elementAt(index))
                                                : colorsUnincluded.add(lightColors.keys.elementAt(index));
                                          });
                                        },
                                      );
                                    },
                                    separatorBuilder: (BuildContext context, int index) {
                                      return const SizedBox(width: 4);
                                    },
                                    itemCount: darkColors.length,
                                  ),
                                ),
                              ),
                              ListTile(
                                title: SizedBox(
                                  height: 48,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return InputChip(
                                        selected: !listsNotIncluded2.contains(index),
                                        label: Text(
                                          tasksLists.value.keys.elementAt(index),
                                          style: TextStyle(
                                            color: !listsNotIncluded2.contains(index)
                                                ? Theme.of(context).scaffoldBackgroundColor
                                                : Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        onSelected: (value) {
                                          setState2(() {
                                            !value ? listsNotIncluded2.add(index) : listsNotIncluded2.remove(index);
                                          });
                                          setState(() {
                                            !value ? listsNotIncluded.add(index) : listsNotIncluded.remove(index);
                                          });
                                        },
                                      );
                                    },
                                    separatorBuilder: (BuildContext context, int index) {
                                      return const SizedBox(
                                        width: 4,
                                      );
                                    },
                                    itemCount: tasksLists.value.length,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
              icon: const Icon(Icons.filter_alt_outlined),
            ),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: streamTask.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: RefreshProgressIndicator(
                color: Colors.red,
              ),
            );
          } else {
            return Body(
              child: SfCalendar(
                onTap: (CalendarTapDetails details) {
                  if (details.appointments != null && details.appointments!.isNotEmpty) {
                    showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        return TaskSheet(
                          task: calendarTasks[details.appointments![0].id],
                          i: 1,
                        );
                      },
                    );
                  }
                },
                scheduleViewMonthHeaderBuilder: scheduleViewHeaderBuilder,
                backgroundColor: Colors.transparent,
                cellBorderColor: Theme.of(context).primaryColor,
                headerHeight: 64,
                headerStyle: CalendarHeaderStyle(
                  textStyle: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                showNavigationArrow: true,
                allowedViews: const [
                  CalendarView.day,
                  CalendarView.week,
                  CalendarView.month,
                  CalendarView.schedule,
                ],
                todayHighlightColor: Theme.of(context).primaryColor,
                allowViewNavigation: true,
                view: calendarView2,
                firstDayOfWeek: firstDay,
                dataSource: MeetingDataSource(getAppointments(tasks)),
              ),
            );
          }
        },
      ),
    );
  }

  Widget scheduleViewHeaderBuilder(BuildContext buildContext, ScheduleViewMonthHeaderDetails details) {
    return Stack(
      children: [
        Container(
          color: lightColors.values.elementAt(details.date.month % lightColors.length).withOpacity(0.4),
          width: details.bounds.width,
          height: details.bounds.height,
        ),
        Center(
          child: Text(
            '${monthNames[details.date.month - 1]} (${details.date.month}) ${details.date.year}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkColors.values.elementAt(details.date.month % lightColors.length),
            ),
          ),
        )
      ],
    );
  }

  List<String> monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
}

List<Appointment> getAppointments(List<Task> q) {
  List<Appointment> meetings = <Appointment>[];
  calendarTasks.clear();
  for (int i = 0; i < q.length; i++) {
    bool notInAnyUnincludedList = true;
    for (int t = 0; t < q[i].list.length; t++) {
      if (listsNotIncluded.contains(tasksLists.value.keys.toList().indexOf(q[i].list[t]))) {
        notInAnyUnincludedList = true;
      }
    }

    if (!q[i].isDeleted &&
        !tagsUnincluded.contains(q[i].tag) &&
        notInAnyUnincludedList &&
        !colorsUnincluded.contains(q[i].color)) {
      calendarTasks.add(q[i]);
    }
  }
  for (int i = 0; i < calendarTasks.length; i++) {
    Task task = calendarTasks[i];
    RecurrenceProperties? recurrence;
    if (task.repeat > 0) {
      recurrence = RecurrenceProperties(
        recurrenceRange: RecurrenceRange.noEndDate,
        startDate: task.due,
        interval: task.repeat,
      );
    }
    final DateTime today = task.due;
    final DateTime endTime = DateTime(
      today.year,
      today.month,
      today.day,
      today.hour,
      today.minute + 60,
    );
    meetings.add(
      Appointment(
        startTime: today,
        endTime: endTime,
        recurrenceRule: recurrence == null ? null : SfCalendar.generateRRule(recurrence, today, endTime),
        notes: task.description,
        subject: task.title,
        color: darkColors[task.color]!,
        isAllDay: false,
        id: i,
      ),
    );
  }

  return meetings;
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}
