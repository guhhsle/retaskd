import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:retaskd/Classes/task.dart';
import 'package:retaskd/Page/page1.dart';
import 'package:retaskd/Page/page2.dart';
import 'package:retaskd/Page/page3.dart';
import 'package:retaskd/Services/floating_home.dart';
import 'package:retaskd/Widgets/home.dart';
import 'package:retaskd/data.dart';
import 'package:retaskd/functions.dart';

import '../other/languages.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  NotesPageState createState() => NotesPageState();
}

class NotesPageState extends State<NotesPage> with TickerProviderStateMixin {
  @override
  void initState() {
    menuController = AnimationController(
      duration: const Duration(milliseconds: 160),
      vsync: this,
    );
    fabController = AnimationController(
      duration: const Duration(milliseconds: 160),
      vsync: this,
    );
    animation = Tween<double>(begin: pi, end: 2 * pi).animate(fabController);
    fabController.forward(from: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool bottom = pf['chipPosition'] == 'Bottom';

    String pos = pf['actionPosition'];
    bool transparent = pf['appbar'] == 'Transparent';
    refreshBox(Theme.of(context));
    return FutureBuilder(
      future: loadLocale(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<String> appBarNames = [l['Tasks'], l['Notes'], l['Recordings']];
          pageName.value = appBarNames[currentPage];
          return Scaffold(
            extendBodyBehindAppBar: true,
            floatingActionButtonLocation: {
                  'End': FloatingActionButtonLocation.endFloat,
                  'Center': FloatingActionButtonLocation.centerFloat
                }[pf['actionPosition']] ??
                FloatingActionButtonLocation.endDocked,
            floatingActionButton: pos == 'Extended'
                ? const FloatingHome()
                : pos == 'End' || pos == 'Center'
                    ? Padding(
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: bottom ? 40 : 16,
                          top: 16,
                        ),
                        child: ValueListenableBuilder<List<Task>>(
                          valueListenable: shownList,
                          builder: (context, data, child) {
                            return FloatingActionButton(
                              onPressed: () {
                                action(context);
                              },
                              tooltip: actionTooltip(),
                              child: ValueListenableBuilder<IconData>(
                                valueListenable: pageIcon,
                                builder: (context, data, child) {
                                  return AnimatedBuilder(
                                    animation: animation,
                                    child: ValueListenableBuilder<String>(
                                      valueListenable: shownTop,
                                      builder: (context, value, child) {
                                        return Icon(
                                          data,
                                          color: value == 'recording'
                                              ? Colors.red
                                              : Theme.of(context).scaffoldBackgroundColor,
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
                          },
                        ),
                      )
                    : null,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ValueListenableBuilder<String>(
                  valueListenable: pageName,
                  builder: (context, value, child) {
                    return AnimatedText(
                      text: value,
                      speed: const Duration(milliseconds: 48),
                      key: ValueKey(value),
                      style: const TextStyle(),
                    );
                  },
                ),
              ),
              actions: homeTools(context),
            ),
            body: Stack(
              children: [
                transparent ? box() : Container(),
                SafeArea(
                  child: ValueListenableBuilder<String>(
                    valueListenable: shownTop,
                    builder: (context, value, child) {
                      return {
                            'recording': const RecordingMenu(),
                            'playing': const PlayingMenu(),
                            'menu': const HomeMenu()
                          }[value] ??
                          Container(
                            width: double.infinity,
                            height: 128,
                            color: Theme.of(context).appBarTheme.backgroundColor,
                          );
                    },
                  ),
                ),
                SafeArea(
                  child: ValueListenableBuilder<String>(
                    valueListenable: shownTop,
                    builder: (context, value, child) {
                      return AnimatedPadding(
                        padding: EdgeInsets.only(
                          top: {'recording': 48.0, 'playing': 48.0, 'menu': 64.0}[value] ?? 0.0,
                        ),
                        curve: Curves.fastOutSlowIn,
                        duration: const Duration(milliseconds: 160),
                        child: Stack(
                          children: [
                            SafeArea(
                              child: Container(
                                color: Theme.of(context).appBarTheme.backgroundColor,
                                width: double.infinity,
                                height: 20,
                              ),
                            ),
                            pos == 'Dock'
                                ? const Align(
                                    alignment: Alignment.bottomCenter,
                                    child: SafeArea(
                                      child: DockedHome(),
                                    ),
                                  )
                                : Container(),
                            SafeArea(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: pos == 'Dock' ? 60 : 0),
                                child: Card(
                                  color: transparent ? Colors.transparent : Theme.of(context).scaffoldBackgroundColor,
                                  margin: EdgeInsets.zero,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Stack(
                                    children: [
                                      transparent ? Container() : box(),
                                      MediaQuery.of(context).orientation == Orientation.landscape
                                          ? Row(
                                              children: [
                                                const Expanded(child: Page1()),
                                                const Expanded(child: Page2()),
                                                kIsWeb ? Container() : const Expanded(child: Page3()),
                                              ],
                                            )
                                          : PageView(
                                              onPageChanged: (int page) {
                                                setPage(page);
                                              },
                                              physics: const BouncingScrollPhysics(),
                                              children: const [Page1(), Page2(), Page3()],
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
