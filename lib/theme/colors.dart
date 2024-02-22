import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Services/google_sign_in.dart';
import '../data.dart';
import '../functions.dart';

Color lighterColor(Color p, Color q) {
  if (p.computeLuminance() > q.computeLuminance()) return p;
  return q;
}

final List<IconData> iconsTheme = [
  Icons.ac_unit_rounded,
  Icons.spa_outlined,
  Icons.local_cafe_outlined,
  Icons.spa_outlined,
  Icons.nature_outlined,
  Icons.filter_drama_rounded,
  Icons.star_purple500_rounded,
  Icons.nature_outlined,
  Icons.filter_drama_rounded,
  Icons.light,
  Icons.spa_outlined,
  Icons.local_cafe_outlined,
  Icons.anchor_outlined,
  Icons.nights_stay_outlined,
  //
  Icons.gradient_rounded,
  Icons.gradient_rounded,
  Icons.gradient_rounded,
  Icons.gradient_rounded,
  Icons.gradient_rounded,
  //
  Icons.grid_3x3_rounded,
  Icons.grid_3x3_rounded,
  Icons.grid_3x3_rounded,
  Icons.grid_3x3_rounded,
  Icons.grid_3x3_rounded,
  Icons.grid_3x3_rounded,
];

Color color(bool primary, bool dark) {
  String name = {
    true: pf[dark ? 'primaryD' : 'primary'],
    false: pf[dark ? 'backgroundD' : 'background'],
  }[primary];
  return colors[name] ?? Color(int.tryParse('0xFF$name') ?? 0xFF170a1c);
}

Color textColor(Color tc, bc) {
  if (pf['appbar'] == 'Primary') {
    return bc;
  } else if (pf['appbar'] == 'Transparent') {
    return tc;
  }
  return lighterColor(tc, bc);
}

void fetchColor(bool p, BuildContext context) {
  Clipboard.getData(Clipboard.kTextPlain).then((value) {
    if (value == null || value.text == null || int.tryParse('0xFF${value.text!.replaceAll('#', '')}') == null) {
      crashDialog(context, 'Clipboard HEX');
    } else {
      setPref(p ? 'primary' : 'background', value.text);
    }
  });
}

List<Setting> colorMap(bool p) {
  List<Setting> l = [
    Setting(
      p ? pf['taskColor'] : pf['noteColor'],
      Icons.tonality_rounded,
      '',
      (c) {},
    ),
  ];
  for (int i = 0; i < (lightColors.length); i++) {
    l.add(
      Setting(
        lightColors.keys.toList()[i],
        Icons.circle,
        '',
        (c) => setPref(
          p ? 'taskColor' : 'noteColor',
          lightColors.keys.elementAt(i),
        ),
        iconColor: lightColors.values.elementAt(i),
      ),
    );
  }
  return l;
}

List<Setting> themeMap(bool p) {
  List<Setting> l = [
    Setting(
      p ? 'Primary' : 'Background',
      Icons.tonality_rounded,
      '',
      (c) => fetchColor(p, c),
    ),
  ];
  for (int i = 0; i < (p ? 14 : colors.length); i++) {
    l.add(
      Setting(
        colors.keys.toList()[i],
        iconsTheme[i],
        '',
        (c) => setPref(
          p ? 'primary' : 'background',
          colors.keys.elementAt(i),
        ),
        iconColor: colors.values.elementAt(i),
      ),
    );
  }
  return l;
}

final Map<String, Color> lightColors = {
  'White': Colors.white,
  'LightOrange': Colors.orange.shade50,
  'Amber': Colors.amber.shade300,
  'Orange': Colors.orange.shade300,
  'DeepOrange': Colors.deepOrange.shade300,
  'Green': const Color(0xFFcbe2d4),
  'Indigo': Colors.indigo.shade100,
  'Blue': Colors.blue.shade400,
  'BlueGrey': Colors.blueGrey,
};

final Map<String, Color> darkColors = {
  'White': Colors.grey.shade900,
  'LightOrange': Colors.amber.shade900,
  'Amber': Colors.amber.shade900,
  'Orange': Colors.orange.shade700,
  'DeepOrange': Colors.deepOrange.shade600,
  'Green': const Color(0xFF374540),
  'Indigo': Colors.indigo.shade400,
  'Blue': Colors.indigo.shade600,
  'BlueGrey': Colors.blueGrey.shade900,
};

final Map<String, Color> colors = {
  'White': Colors.white,
  'Pink': const Color(0xFFFEDBD0),
  'Gruv Light': const Color(0xFFd4be98),
  'PinkRed': const Color(0xFFcf6679),
  'Light Green': const Color(0xFFcbe2d4),
  'BlueGrey': Colors.blueGrey,
  'Purple': const Color(0xFF906fff),
  'Dark Green': const Color(0xFF374540),
  'Dark BlueGrey': Colors.blueGrey.shade900,
  'Purple Grey': const Color(0xFF282a36),
  'Dark Pink': const Color(0xFF442C2E),
  'Gruv Dark': const Color(0xFF282828),
  'Anchor': const Color(0xFF11150D),
  'Black': Colors.black,
  //
  'Gradient Light': Colors.white,
  'Gradient Green': Colors.white,
  'Gradient Prime': Colors.white,
  'Gradient DeepSea': Colors.white,
  'Gradient PurplePink': Colors.white,
  //
  'Grid White': Colors.white,
  'Grid Pink': const Color(0xFFFEDBD0),
  'Grid Gruv Light': const Color(0xFFd4be98),
  'Grid Green': const Color(0xFFcbe2d4),
  'Grid Grey': Colors.blueGrey,
  'Grid Black': Colors.black,
};

final Map<String, List<Color>> gradients = {
  'Gradient Light': [const Color(0xFFFFC2C2), const Color(0xFFFFD7A8)],
  'Gradient Green': [const Color(0xFF9DFFB3), const Color(0xFF1AA37A)],
  'Gradient Prime': [const Color(0xFFA0B5EB), const Color(0xFFC9F0E4)],
  'Gradient DeepSea': [const Color(0xFF26D0CE), const Color(0xFF1A2980)],
  'Gradient PurplePink': [const Color(0xFF6A11CB), const Color(0xFFFC6767)],
};
