import 'package:retaskd/Functions/audio_functions.dart';
import 'package:retaskd/Functions/task_functions.dart';
import 'package:retaskd/Page/calendar.dart';
import 'package:retaskd/Sheets/sheet_add_note.dart';
import 'package:retaskd/Sheets/sheet_add_task.dart';
import 'package:flutter/material.dart';
import 'package:retaskd/data.dart';
import '../functions.dart';

class DockedHome extends StatefulWidget {
  const DockedHome({Key? key}) : super(key: key);

  @override
  DockedHomeState createState() => DockedHomeState();
}

class DockedHomeState extends State<DockedHome> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: shownList,
      builder: (context, data, child) {
        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Container(
              height: 20,
              color: Theme.of(context).appBarTheme.backgroundColor,
            ),
            Container(
              height: 60,
              width: double.infinity,
              color: Theme.of(context).appBarTheme.backgroundColor,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          tooltip: l['Calendar'],
                          color: Theme.of(context).appBarTheme.foregroundColor,
                          icon: const Icon(Icons.calendar_view_week_rounded),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PageCalendar()),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                      tooltip: l['Record voice'],
                      icon: ValueListenableBuilder<String>(
                        valueListenable: shownTop,
                        builder: (context, value, child) {
                          return Icon(
                            Icons.multitrack_audio_rounded,
                            color: value == 'recording' ? Colors.red : Theme.of(context).appBarTheme.foregroundColor,
                            size: 24,
                          );
                        },
                      ),
                      onPressed: toggle),
                  IconButton(
                    tooltip: l['Add note'],
                    icon: Icon(
                      Icons.edit_outlined,
                      color: Theme.of(context).appBarTheme.foregroundColor,
                      size: 24,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return const SheetAddNote();
                        },
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: AnimatedBuilder(
                      animation: animation,
                      child: IconButton(
                        icon: Icon(
                          data == deletedTasks && currentPage == 0 ? Icons.delete_forever : Icons.add,
                          color: Theme.of(context).appBarTheme.foregroundColor,
                          size: 24,
                        ),
                        tooltip: data == deletedTasks && currentPage == 0 ? l['Delete all'] : l['Add task'],
                        onPressed: () {
                          if (data == deletedTasks && currentPage == 0) {
                            customCrashDialog(l['Press again to permanently delete done tasks'], () {
                              deleteDeletedTasks();
                              setPage(currentPage);
                            }, context);
                          } else {
                            showModalBottomSheet(
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
                          }
                        },
                      ),
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: animation.value,
                          child: child,
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class FloatingHome extends StatefulWidget {
  const FloatingHome({Key? key}) : super(key: key);

  @override
  FloatingHomeState createState() => FloatingHomeState();
}

class FloatingHomeState extends State<FloatingHome> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: shownList,
      builder: (context, data, child) {
        return Card(
          elevation: 4,
          shadowColor: Theme.of(context).primaryColor,
          margin: const EdgeInsets.only(left: 32, bottom: 16),
          color: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        tooltip: l['Calendar'],
                        color: Theme.of(context).scaffoldBackgroundColor,
                        icon: const Icon(Icons.calendar_view_week_rounded),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const PageCalendar()));
                        },
                      ),
                    ),
                  ),
                ),
                IconButton(
                    tooltip: l['Record voice'],
                    icon: ValueListenableBuilder<String>(
                      valueListenable: shownTop,
                      builder: (context, value, child) {
                        return Icon(
                          Icons.multitrack_audio_rounded,
                          color: value == 'recording' ? Colors.red : Theme.of(context).scaffoldBackgroundColor,
                          size: 24,
                        );
                      },
                    ),
                    onPressed: toggle),
                IconButton(
                  tooltip: l['Add note'],
                  icon: Icon(Icons.edit_outlined, color: Theme.of(context).scaffoldBackgroundColor, size: 24),
                  onPressed: () {
                    showModalBottomSheet(
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      elevation: 32,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        return const SheetAddNote();
                      },
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: AnimatedBuilder(
                    animation: animation,
                    child: IconButton(
                      icon: Icon(
                        data == deletedTasks && currentPage == 0 ? Icons.delete_forever : Icons.add,
                        color: Theme.of(context).scaffoldBackgroundColor,
                        size: 24,
                      ),
                      tooltip: data == deletedTasks && currentPage == 0 ? l['Delete all'] : l['Add task'],
                      onPressed: () {
                        if (data == deletedTasks && currentPage == 0) {
                          customCrashDialog(l['Press again to permanently delete done tasks'], () {
                            deleteDeletedTasks();
                            setPage(currentPage);
                          }, context);
                        } else {
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
                        }
                      },
                    ),
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: animation.value,
                        child: child,
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
