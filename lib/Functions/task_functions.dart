import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:retaskd/Classes/task.dart';
import 'package:retaskd/Services/notif_controller.dart';
import 'package:retaskd/data.dart';
import 'package:retaskd/functions.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

import '../theme/colors.dart';

StreamSubscription<QuerySnapshot<Map<String, dynamic>>> listenTasks(User us) {
  streamTask = FirebaseFirestore.instance.collection('users').doc(us.uid).collection('tasks');
  return streamTask.snapshots().listen(
    (data) {
      tasks.clear();
      for (var i = 0; i < data.docs.length; i++) {
        Task task = Task.fromJson(data.docs[i].data());
        task.id = data.docs[i].id;
        tasks.add(task);
      }
      refreshTasks();
    },
  );
}

void refreshNotif() {
  NotificationController.cancelNotifications();
  for (int i = 0; i < tasks.length; i++) {
    if (tasks[i].notif > -1) {
      NotificationController.scheduleNewNotification(tasks[i]);
    }
  }
}

void deleteDeletedTasks() async {
  shownList.value = pendingTasks;
  for (int i = 0; i < tasks.length; i++) {
    if (tasks[i].isDeleted) {
      tasks[i].delete();
    }
  }
}

void refreshTasks() async {
  deletedTasks.clear();
  pendingTasks.clear();
  Map<String, List<Task>> map = Map<String, List<Task>>.from(tasksLists.value);
  for (var i = 0; i < map.length; i++) {
    map.values.elementAt(i).clear();
  }
  tasks.sort((a, b) {
    return {
      'Date, Asc': b.due.compareTo(a.due),
      'Date, Desc': a.due.compareTo(b.due),
      'Name, Asc': b.title.compareTo(a.title),
      'Name, Desc': a.title.compareTo(b.title),
      'Color, Asc': darkColors.keys.toList().indexOf(b.color).compareTo(darkColors.keys.toList().indexOf(a.color)),
      'Color, Desc': darkColors.keys.toList().indexOf(a.color).compareTo(darkColors.keys.toList().indexOf(b.color)),
    }[pf['sortTasks']]!;
  });

  thisWeek.clear();

  for (int i = 0; i < tasks.length; i++) {
    Task task = tasks[i];
    if (!task.isDeleted) {
      for (int l = 0; l < task.list.length; l++) {
        String prnt = task.list[l];
        while (prnt != '') {
          if (!map.containsKey(prnt)) {
            map.addAll({prnt: []});
          }
          prnt = parentOfFolder(prnt);
        }
      }
    }
  }

  for (int i = 0; i < tasks.length; i++) {
    Task task = tasks[i];
    if (task.isDeleted) {
      deletedTasks.insert(0, task);
    } else if (task.list.isEmpty) {
      pendingTasks.insert(0, task);
    }
    if (!task.isDeleted || pf['doneInList']) {
      for (int t = 0; t < task.list.length; t++) {
        map[task.list[t]]!.insert(0, task);
      }
    }
    if (!task.isDeleted &&
        task.due.isAfter(DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        )) &&
        task.due.isBefore(DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day + 7,
        ))) {
      thisWeek.insert(0, task);
    }
  }
  if (shownList.value == deletedTasks && deletedTasks.isEmpty) {
    shownList.value = pendingTasks;
    setPage(currentPage);
  }
  tasksLists.value = map;
  if (!kIsWeb) {
    refreshNotif();
  }
}

ValueNotifier<String> parentTaskFolder = ValueNotifier('');

Map<String, String> relativeFolders({String? prnt}) {
  prnt ??= parentTaskFolder.value;
  Map<String, String> map = <String, String>{};
  for (int i = 0; i < tasksLists.value.length; i++) {
    String fullName = tasksLists.value.keys.toList()[i];
    if (prnt == parentOfFolder(fullName)) {
      map[relativeName(fullName)] = fullName;
    }
  }
  return map;
}

String parentOfFolder(String folder) {
  for (int i = folder.length - 1; i >= 0; i--) {
    if (folder[i] == '/') {
      folder = folder.substring(0, i);
      break;
    }
    folder = folder.substring(0, i);
  }
  return folder;
}

String relativeName(String fullName) {
  String newParent = fullName.replaceAll('${parentTaskFolder.value}/', '');
  String finalName = '';
  for (int i = 0; i < newParent.length; i++) {
    if (newParent[i] == '/') break;
    finalName += newParent[i];
  }
  return finalName;
}
