import 'package:flutter/material.dart';

import '../Functions/task_functions.dart';
import '../Sheets/sheet_list.dart';
import '../data.dart';
import '../functions.dart';
import 'custom_chip.dart';
import 'home.dart';

Container chipList(BuildContext context) {
  bool bottom = pf['chipPosition'] == 'Bottom';
  bool e = pf['actionPosition'] == 'Extended';
  double q = bottom ? 1 : 0;
  double w = bottom ? 0 : 1;
  return Container(
    height: tasksLists.value.isEmpty && deletedTasks.isEmpty && thisWeek.isEmpty ? 24 * w : 64 + q * (e ? 64 : 18),
    padding: EdgeInsets.only(
      left: 16,
      right: 16,
      top: bottom ? 0 : 16,
      bottom: e ? 82 * q : 4,
    ),
    child: ValueListenableBuilder<String>(
      valueListenable: parentTaskFolder,
      builder: (context, parent, child) {
        return ListView(
          scrollDirection: Axis.horizontal,
          reverse: bottom,
          physics: const BouncingScrollPhysics(),
          children: [
            parent != ''
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, right: 8),
                    child: Chip(
                      deleteIcon: Text(
                        '/',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.background,
                        ),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                      onDeleted: () {
                        parentTaskFolder.value = parentOfFolder(parentTaskFolder.value);
                        shownList.value = tasksLists.value[parentTaskFolder.value] ?? pendingTasks;
                      },
                      label: AnimatedText(
                        text: parent,
                        speed: const Duration(milliseconds: 64),
                        key: ValueKey(parent),
                        style: TextStyle(color: Theme.of(context).colorScheme.background),
                      ),
                    ),
                  )
                : thisWeek.isNotEmpty && pf['shownLists'].contains('This week')
                    ? CustomChip(
                        onLongPress: () {},
                        onSelected: (bool value) {
                          shownList.value = value ? thisWeek : pendingTasks;
                          pageIcon.value = Icons.add_rounded;
                        },
                        selected: shownList.value == thisWeek,
                        label: l['This week'],
                      )
                    : Container(),
            ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: relativeFolders().keys.length,
              reverse: bottom,
              itemBuilder: (context, index) {
                String shortName = relativeFolders().keys.elementAt(index);
                String fullName = relativeFolders().values.elementAt(index);
                return CustomChip(
                  onLongPress: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return SheetTaskList(listName: fullName);
                      },
                    );
                  },
                  onSelected: (value) {
                    if (relativeFolders(prnt: fullName).isNotEmpty) {
                      parentTaskFolder.value = fullName;
                      shownList.value = tasksLists.value[fullName] ?? pendingTasks;
                    } else if (shownList.value == tasksLists.value[fullName]) {
                      shownList.value = tasksLists.value[parentOfFolder(fullName)] ?? pendingTasks;
                    } else {
                      shownList.value = tasksLists.value[fullName] ?? pendingTasks;
                    }
                    pageIcon.value = Icons.add_rounded;
                  },
                  selected: shownList.value == tasksLists.value[fullName],
                  label: shortName,
                );
              },
            ),
            deletedTasks.isNotEmpty && pf['shownLists'].contains('Done') && parent == ''
                ? CustomChip(
                    onLongPress: () {},
                    onSelected: (bool value) {
                      shownList.value = value ? deletedTasks : pendingTasks;
                      setPage(currentPage);
                    },
                    selected: shownList.value == deletedTasks,
                    label: l['Done'],
                  )
                : Container(),
          ],
        );
      },
    ),
  );
}
