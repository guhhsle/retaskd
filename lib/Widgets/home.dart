// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:retaskd/Functions/audio_functions.dart';
import 'package:retaskd/Page/archive.dart';
import 'package:retaskd/Page/calendar.dart';
import 'package:retaskd/Page/settings.dart';
import 'package:retaskd/Page/trash.dart';
import 'package:retaskd/Services/dialog_pass.dart';
import 'package:retaskd/Services/local_auth.dart';
import 'package:retaskd/Sheets/sheet_add_note.dart';
import 'package:retaskd/Widgets/search.dart';
import 'package:retaskd/data.dart';
import 'package:retaskd/functions.dart';

class HomeMenu extends StatelessWidget {
  const HomeMenu({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor,
      height: 64,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [for (int i = 0; i < 4; i++) MenuCard(i: i)],
      ),
    );
  }
}

class RecordingMenu extends StatelessWidget {
  const RecordingMenu({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor,
      height: 48,
      child: Center(
        child: StreamBuilder(
          stream: Stream.periodic(const Duration(seconds: 1)),
          builder: (context, snapshot) {
            return Text(
              elapsed(dt.elapsed),
              style: const TextStyle(
                color: Colors.red,
                backgroundColor: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            );
          },
        ),
      ),
    );
  }
}

String elapsed(Duration el) {
  String text = '';
  if (el.inMinutes > 9) {
    text = '$text$el.inMinutes';
  } else {
    text = '${text}0${el.inMinutes}';
  }
  text = '$text : ';
  if (el.inSeconds % 60 > 9) {
    text = '$text${el.inSeconds % 60} ';
  } else {
    text = '${text}0${el.inSeconds % 60} ';
  }
  return text;
}

class PlayingMenu extends StatelessWidget {
  const PlayingMenu({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor,
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ValueListenableBuilder<bool>(
              valueListenable: isPaused,
              builder: (context, data, child) {
                return IconButton(
                  tooltip: data ? l['Play'] : l['Pause'],
                  onPressed: () {
                    togglePlayer();
                  },
                  icon: Icon(
                    data ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                );
              }),
          StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 1)),
            builder: (context, snapshot) {
              return Text(
                elapsed(pt.elapsed),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).appBarTheme.foregroundColor,
                ),
              );
            },
          ),
          IconButton(
            tooltip: l['Close'],
            onPressed: () {
              endPlayer();
            },
            icon: Icon(
              Icons.close_rounded,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}

class MenuCard extends StatelessWidget {
  final int i;
  const MenuCard({Key? key, required this.i}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<IconData> iconsTheme = [
      Icons.delete_outline_rounded,
      Icons.tune_rounded,
      Icons.folder_outlined,
      Icons.calendar_view_week_rounded,
    ];
    List<String> titles = ['Trash', 'Settings', 'Archive', 'Calendar'];
    return IconButton(
      tooltip: l[titles[i]],
      onPressed: () async {
        bool isAuthenticated = true;
        if (i == 2 && pf['title'] == 'biometricsBiometrics') {
          isAuthenticated = false;
          isAuthenticated = await LocalAuthApi.authenticate();
        } else if (i == 2 && pf['title'] != '') {
          isAuthenticated = false;
          showDialog(
            barrierDismissible: true,
            context: context,
            builder: (BuildContext context) => DialogPass(
              onDone: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PageArchived(),
                ),
              ),
            ),
          );
        }
        if (isAuthenticated) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => {
                0: const PageTrash(),
                1: const PageSettings(),
                2: const PageArchived(),
                3: const PageCalendar(),
              }[i]!,
            ),
          );
        }
        homeMenu();
      },
      icon: Icon(
        iconsTheme[i],
        color: Theme.of(context).appBarTheme.foregroundColor,
      ),
    );
  }
}

class AnimatedText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration speed;
  const AnimatedText({Key? key, required this.text, required this.speed, required this.style}) : super(key: key);

  @override
  State<AnimatedText> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText> {
  bool paused = false;
  String title = '';

  @override
  Widget build(BuildContext context) {
    Stream titleStream = Stream.periodic(widget.speed);
    if (paused) {
      return Text(
        title,
        style: widget.style,
      );
    }
    return StreamBuilder(
      stream: titleStream,
      builder: (context, snapshot) {
        if (title == widget.text) {
          Future.delayed(
            const Duration(milliseconds: 1),
            () => setState(() => paused = true),
          );
        } else {
          title = title + widget.text[title.length];
        }
        return Text(
          title,
          style: widget.style,
        );
      },
    );
  }
}

List<Widget> homeTools(context) {
  List<Widget> widgets = [];
  if (pf['actionPosition'] == 'Top') {
    widgets.add(
      ValueListenableBuilder<IconData>(
        valueListenable: pageIcon,
        builder: (context2, data, child) {
          return AnimatedBuilder(
            animation: animation,
            child: ValueListenableBuilder<String>(
              valueListenable: shownTop,
              builder: (context2, value, child) {
                return IconButton(
                  icon: Icon(data),
                  onPressed: () {
                    action(context);
                  },
                  tooltip: actionTooltip(),
                  color: value == 'recording' ? Colors.red : null,
                );
              },
            ),
            builder: (context, child) {
              return Transform.rotate(
                angle: animation.value,
                child: child,
              );
            },
          );
        },
      ),
    );
  }
  if (pf['actionPosition'] == 'Top' && MediaQuery.of(context).orientation == Orientation.landscape) {
    setPage(0);
    int f = kIsWeb ? 1 : 2;
    for (int i = 0; i < f; i++) {
      widgets.add(
        ValueListenableBuilder<String>(
          valueListenable: shownTop,
          builder: (context2, value, child) {
            return IconButton(
              icon: Icon(pageIcons[i + 1]),
              onPressed: () {
                if (i == 0) {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    isScrollControlled: true,
                    builder: (context) => const SheetAddNote(),
                  );
                } else {
                  toggle();
                }
              },
              tooltip: i == 0 ? l['Add note'] : l['Record voice'],
              color: value == 'recording' ? Colors.red : null,
            );
          },
        ),
      );
    }
  }

  widgets.add(
    IconButton(
      onPressed: () => showSearch(context: context, delegate: Delegate()),
      tooltip: l['Search'],
      icon: const Icon(Icons.fiber_manual_record_outlined),
    ),
  );
  widgets.add(
    Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        onPressed: () => homeMenu(),
        tooltip: l['Menu'],
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: menuController,
        ),
      ),
    ),
  );

  return widgets;
}
