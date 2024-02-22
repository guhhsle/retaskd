import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data.dart';
import '../functions.dart';

Future<int> loadLocale() async {
  final String response = await rootBundle.loadString('assets/translations/${pf['locale']}.json');
  l = await json.decode(response);
  return 0;
}

List<Setting> languageMap() {
  List<Setting> l = [
    Setting(
      'Language',
      Icons.language_rounded,
      '',
      (c) {},
    ),
  ];
  for (int i = 0; i < languages.length; i++) {
    l.add(
      Setting(
        languages.values.elementAt(i),
        Icons.language_rounded,
        '',
        (c) {
          setPref('locale', languages.keys.elementAt(i));
          loadLocale();
        },
      ),
    );
  }
  return l;
}
