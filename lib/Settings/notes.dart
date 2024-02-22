import 'package:flutter/material.dart';

import '../Functions/note_functions.dart';
import '../Widgets/sheet_scroll_model.dart';
import '../data.dart';
import '../functions.dart';
import '../theme/colors.dart';

List<Setting> notesSet() => [
      Setting(
        'Note color',
        Icons.circle_rounded,
        'pf//noteColor',
        (c) {
          showModalBottomSheet(
            context: c,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (context) {
              return SheetScrollModel(
                list: colorMap(false),
              );
            },
          );
        },
      ),
      Setting(
        'Gridview',
        Icons.space_dashboard_rounded,
        'pf//grid',
        (c) => revPref('grid'),
      ),
      Setting(
        'Adaptive note',
        Icons.tonality_rounded,
        'pf//noteAdaptive',
        (c) => nextPref(
          'noteAdaptive',
          ['Custom', 'Transparent', 'Primary'],
        ),
      ),
      Setting(
        'Sort by',
        Icons.sort_rounded,
        'pf//sortNotes',
        (c) {
          nextPref(
            'sortNotes',
            [
              'Date, Asc',
              'Date, Desc',
              'Name, Asc',
              'Name, Desc',
              'Color, Asc',
              'Color, Desc',
            ],
          );
          refreshNotes();
        },
      ),
    ];
