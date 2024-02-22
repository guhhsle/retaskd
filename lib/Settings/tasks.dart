import 'package:flutter/material.dart';
import 'package:retaskd/Functions/task_functions.dart';

import '../Widgets/sheet_scroll_model.dart';
import '../data.dart';
import '../functions.dart';
import '../theme/colors.dart';

List<Setting> tasksSet() => [
      Setting(
        'Task color',
        Icons.circle_rounded,
        'pf//taskColor',
        (c) {
          showModalBottomSheet(
            context: c,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (context) {
              return SheetScrollModel(
                list: colorMap(true),
              );
            },
          );
        },
      ),
      Setting(
        'Show done tasks in lists',
        Icons.done_rounded,
        'pf//doneInList',
        (c) => setPref(
          'doneInList',
          !pf['doneInList'],
        ),
      ),
      Setting(
        'Adaptive task',
        Icons.tonality_rounded,
        'pf//taskAdaptive',
        (c) => nextPref('taskAdaptive', ['Transparent', 'Primary', 'Custom']),
      ),
      Setting(
        'Notifications',
        Icons.notifications_rounded,
        'pf//notifications',
        (c) => nextPref(
          'notifications',
          ['Morning', 'Custom', 'None'],
        ),
      ),
      Setting(
        'Sort by',
        Icons.sort_rounded,
        'pf//sortTasks',
        (c) {
          nextPref(
            'sortTasks',
            [
              'Date, Asc',
              'Date, Desc',
              'Name, Asc',
              'Name, Desc',
              'Color, Asc',
              'Color, Desc',
            ],
          );
          refreshTasks();
        },
      ),
      Setting(
        'Shown lists',
        Icons.tag_rounded,
        'pf//shownLists',
        (c) => nextPref(
          'shownLists',
          ['Done && This week', 'Done', 'This week', ''],
        ),
      ),
      Setting(
        'Checkbox',
        Icons.check_box_outline_blank_rounded,
        'pf//checkbox',
        (c) {
          nextPref('checkbox', ['Left', 'Right']);
          refreshTasks();
        },
      ),
    ];
