import 'package:flutter/material.dart';
import 'package:retaskd/functions.dart';

import '../data.dart';

List<Setting> audioSet() => [
      Setting(
        'Codec',
        Icons.graphic_eq_rounded,
        'pf//codec',
        (c) => nextPref(
          'codec',
          //opus, caf, ogg, mp3
          ['m4a', 'aac', 'wav'],
        ),
      ),
      Setting(
        'Transparent',
        Icons.tonality_rounded,
        'pf//transparentRec',
        (c) => revPref('transparentRec'),
      ),
      Setting(
        'pf//recDirectory',
        Icons.folder_rounded,
        '',
        (c) {},
      ),
    ];
