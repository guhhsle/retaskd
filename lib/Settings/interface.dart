import 'package:flutter/material.dart';
import 'package:retaskd/functions.dart';

import '../data.dart';

List<Setting> interfaceSet() => [
      Setting(
        'Action button',
        Icons.track_changes_rounded,
        'pf//actionPosition',
        (c) => nextPref(
          'actionPosition',
          ['Center', 'Extended', 'Dock', 'End', 'Top'],
        ),
      ),
      Setting(
        'Appbar',
        Icons.tonality_rounded,
        'pf//appbar',
        (c) => nextPref(
          'appbar',
          ['Transparent', 'Black', 'Primary'],
        ),
      ),
      Setting(
        'Chip position',
        Icons.toll_rounded,
        'pf//chipPosition',
        (c) => nextPref(
          'chipPosition',
          ['Top', 'Bottom'],
        ),
      ),
      Setting(
        'Font',
        Icons.format_italic_rounded,
        'pf//font',
        (c) => nextPref(
          'font',
          [
            'JetBrainsMono',
            'RobotoMono',
            'IBMPlexMono',
            'Roboto',
            'Pacifico',
          ],
        ),
      ),
      Setting(
        'Weekday',
        Icons.date_range_rounded,
        'pf//weekday',
        (c) => nextPref(
          'weekday',
          ['Monday', 'Saturday', 'Sunday'],
        ),
      ),
      Setting(
        'Calendar view',
        Icons.calendar_view_day_rounded,
        'pf//calendarView',
        (c) => nextPref(
          'calendarView',
          ['Schedule', 'Month', 'Week'],
        ),
      ),
      Setting(
        'Reverse lists',
        Icons.low_priority_rounded,
        'pf//reverseList',
        (c) => setPref(
          'reverseList',
          !pf['reverseList'],
        ),
      ),
    ];
