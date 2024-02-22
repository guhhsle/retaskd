import 'package:flutter/material.dart';
import 'package:retaskd/functions.dart';
import 'package:retaskd/license.dart';
import 'package:retaskd/log.dart';

import '../Widgets/sheet_scroll_model.dart';
import '../data.dart';
import '../other/languages.dart';

List<Setting> moreSet() => [
      Setting(
        'Version',
        Icons.moped_rounded,
        '',
        (c) => singleChildSheet(
          title: 'Versions',
          icon: Icons.segment_rounded,
          child: Text(updates),
          context: c,
        ),
      ),
      Setting(
        'License',
        Icons.segment_rounded,
        'GNU GPL3',
        (c) => singleChildSheet(
          title: 'GNU GPL3',
          icon: Icons.segment_rounded,
          child: Text(license),
          context: c,
        ),
      ),
      Setting(
        'Language',
        Icons.language_rounded,
        'pf//locale',
        (c) {
          showModalBottomSheet(
            context: c,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (c) => SheetScrollModel(list: languageMap()),
          );
        },
      ),
      Setting(
        'Marko',
        Icons.moped_rounded,
        '',
        (c) {},
      ),
    ];
