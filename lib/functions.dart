import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:retaskd/Functions/audio_functions.dart';
import 'package:retaskd/Functions/task_functions.dart';
import 'package:retaskd/Sheets/sheet_add_note.dart';
import 'package:retaskd/Sheets/sheet_add_task.dart';
import 'package:retaskd/data.dart';
import 'package:retaskd/theme/colors.dart';
import 'package:retaskd/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Widgets/custom_card.dart';

Future<void> initPrefs() async {
  prefs = await SharedPreferences.getInstance();
  for (var i = 0; i < pf.length; i++) {
    String key = pf.keys.elementAt(i);
    if (pf[key] is String) {
      if (prefs.getString(key) == null) {
        prefs.setString(key, pf[key]);
      } else {
        pf[key] = prefs.getString(key)!;
      }
    } else if (pf[key] is int) {
      if (prefs.getInt(key) == null) {
        prefs.setInt(key, pf[key]);
      } else {
        pf[key] = prefs.getInt(key)!;
      }
    } else if (key == 'firstBoot') {
      if (prefs.getBool('firstBoot') == null) {
        prefs.setBool('firstBoot', false);
      } else {
        pf['firstBoot'] = false;
      }
    } else if (pf[key] is bool) {
      if (prefs.getBool(key) == null) {
        prefs.setBool(key, pf[key]);
      } else {
        pf[key] = prefs.getBool(key)!;
      }
    }
  }
}

Widget box() {
  if ((background.contains('Grid') || background.contains('Gradient'))) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: background.contains('Grid')
          ? ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: gp,
            )
          : AnimatedContainer(
              duration: const Duration(seconds: 1),
              decoration: bd,
              height: double.infinity,
              width: double.infinity,
            ),
    );
  }
  return Container();
}

Future sync() async {
  await FirebaseFirestore.instance.enableNetwork();
  await Future.delayed(Duration(seconds: pf['syncTimeout']));
  await FirebaseFirestore.instance.disableNetwork();
}

void action(BuildContext context) {
  if (shownList.value == deletedTasks && currentPage == 0) {
    customCrashDialog(l['Press again to permanently delete done tasks'], () {
      deleteDeletedTasks();
      setPage(currentPage);
    }, context);
  } else if (currentPage == 2) {
    toggle();
  } else {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      isScrollControlled: true,
      builder: (context) {
        return currentPage == 0 ? const SheetAddTask() : const SheetAddNote();
      },
    );
  }
}

String actionTooltip() {
  if (shownList.value == deletedTasks && currentPage == 0) {
    return l['Delete all'];
  }
  List<String> list = [l['Add task'], l['Add note'], l['Record voice']];
  return list[currentPage];
}

void customCrashDialog(
  String text,
  void Function() onTap,
  BuildContext context,
) {
  showDialog(
    context: context,
    builder: (context) {
      return Center(
        child: Card(
          color: Theme.of(context).colorScheme.background,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: DefaultTextStyle(
              style: const TextStyle(),
              child: TextButton(
                child: Text(
                  text,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  onTap();
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ),
      );
    },
  );
}

void refreshBox(ThemeData theme) {
  bool dark = theme.brightness == Brightness.dark;
  primary = pf[dark ? 'primaryD' : 'primary'];
  background = pf[dark ? 'backgroundD' : 'background'];
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: pf['actionPosition'] == 'Dock'
          ? (pf['appbar'] == 'Primary'
              ? theme.primaryColor
              : pf['appbar'] == 'Black'
                  ? Colors.black
                  : theme.navigationBarTheme.backgroundColor)
          : theme.navigationBarTheme.backgroundColor,
    ),
  );
  bd = BoxDecoration(borderRadius: BorderRadius.circular(20));
  if (background.startsWith('Grid')) {
    gp = GridPaper(
      color: {
        'Grid White': Colors.grey.shade200,
        'Grid Pink': Colors.pink.shade100,
        'Grid Gruv Light': Colors.brown.shade100,
        'Grid Green': Colors.white,
        'Grid Grey': Colors.blueGrey.shade400,
        'Grid Black': Colors.grey.shade700,
      }[background]!,
    );
  } else if (background.contains('Gradient')) {
    bd = BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradients[background]!,
      ),
    );
  }
}

void homeMenu() {
  if (shownTop.value == 'menu') {
    menuController.reverse();
    shownTop.value = 'none';
  } else {
    menuController.forward();
    shownTop.value = 'menu';
  }
}

List<IconData> pageIcons = [
  Icons.add,
  Icons.edit_outlined,
  Icons.record_voice_over_outlined,
  Icons.delete_forever,
];

void setPage(int page) {
  List<String> appBarNames = [l['Tasks'], l['Notes'], l['Recordings']];
  pageName.value = appBarNames[page];
  pageIcon.value = page == 0 && shownList.value == deletedTasks ? pageIcons[3] : pageIcons[page];
  currentPage = page;
  animation = Tween<double>(begin: pi, end: 2 * pi).animate(fabController);
  fabController.forward(from: 0);
}

void goToPage(int pa) {
  wPageController.animateToPage(
    pa,
    duration: const Duration(milliseconds: 600),
    curve: Curves.fastLinearToSlowEaseIn,
  );
  pageSelected.value = pa;
}

void setPref(String pString, var value) {
  pf[pString] = value;
  if (value is int) {
    prefs.setInt(pString, value);
  } else if (value is bool) {
    prefs.setBool(pString, value);
  } else if (value is String) {
    prefs.setString(pString, value);
  }
  themeNotifier.value = themeData(
    tc: color(true, false),
    bc: color(true, false),
    dark: false,
  );
}

void nextPref(String pref, List<String> list) {
  setPref(pref, list[(list.indexOf(pf[pref]) + 1) % list.length]);
}

void revPref(String pref) {
  setPref(pref, !pf[pref]);
}

String t(dynamic d) {
  String s = '$d';
  if (s.startsWith('pf//')) {
    return t(pf[s.replaceAll('pf//', '')]);
  }
  return l[s] ?? s;
}

Future<void> singleChildSheet({
  required String title,
  required IconData icon,
  required Widget child,
  required BuildContext context,
}) async {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        color: Colors.transparent,
        child: DraggableScrollableSheet(
          initialChildSize: 0.4,
          maxChildSize: 0.75,
          minChildSize: 0.2,
          builder: (_, controller) {
            return Card(
              margin: const EdgeInsets.all(8),
              color: Theme.of(context).colorScheme.background,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    CustomCard(
                      title: title,
                      onTap: () {},
                      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      child: Icon(icon),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
                        physics: const BouncingScrollPhysics(),
                        controller: controller,
                        child: Center(
                          child: DefaultTextStyle(
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.primary,
                              fontFamily: pf['font'],
                              fontWeight: FontWeight.bold,
                            ),
                            child: child,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
