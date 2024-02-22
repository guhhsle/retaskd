import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:retaskd/Classes/note.dart';
import 'package:retaskd/Classes/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Map<String, IconData> icons = {
  'None': Icons.circle_outlined,
  'Suitcase': Icons.work_rounded,
  'School': Icons.school_rounded,
  'Construction': Icons.construction_rounded,
  'Psychology': Icons.psychology,
  'Travel': Icons.luggage_rounded,
  'Lightbulb': Icons.lightbulb_outlined,
  'CreditCard': Icons.credit_card_rounded,
  'Cafe': Icons.local_cafe_outlined,
  'Moped': Icons.moped_rounded,
  'NodeTree': Icons.account_tree_rounded,
  'Sofa': Icons.chair_rounded,
  'Savings': Icons.savings_rounded
};
List<String> taskIDs = [];
late CollectionReference<Map<String, dynamic>> streamNote;
late CollectionReference<Map<String, dynamic>> streamTask;
int currentPage = 0;

List<Widget> noteWidgets = [];

late User user;

List<String> recNames = [];
ValueNotifier<String> pageName = ValueNotifier('Tasks');
ValueNotifier<IconData> pageIcon = ValueNotifier(Icons.add);
ValueNotifier<bool> isPaused = ValueNotifier(false);
Stopwatch dt = Stopwatch();
Stopwatch pt = Stopwatch();
FlutterSoundRecorder rec = FlutterSoundRecorder();
FlutterSoundPlayer player = FlutterSoundPlayer();
ValueNotifier<Note> noteNote = ValueNotifier(Note(createdTime: DateTime.now()));

Map pf = {
  'firstBoot': true,
  'title': '',
  'locale': 'en',
  //
  'background': 'Grid White',
  'primary': 'Black',

  'backgroundD': 'Anchor',
  'primaryD': 'Light Green',
  //
  //'firstDay': 0,
  'weekday': 'Monday',
  'calendarView': 'Schedule',
  'actionPosition': 'Top',
  'appbar': 'Black',
  'chipPosition': 'Top',
  'reverseList': false,
  'font': 'JetBrainsMono',
  //
  'taskColor': 'White',
  'taskAdaptive': 'Transparent',
  'notifications': 'Custom',
  'doneInList': true,
  'sortTasks': 'Date, Asc',
  'shownLists': 'Done && This week',
  'checkbox': 'Right',
  //
  'noteColor': 'Orange',
  'noteAdaptive': 'Custom',
  'grid': false,
  'sortNotes': 'Name, Asc',
  //
  'recDirectory': '',
  'transparentRec': true,
  'codec': 'm4a',
  //Account
  'syncTimeout': 6
};

Map<String, FirebaseOptions?> firebaseOptions = {
  'Android': null,
  'Web': const FirebaseOptions(
    apiKey: "AIzaSyCTH0aG6tfOXuEjfpUd91Om5JwSY09vV0s",
    authDomain: "retaskd-cb23e.firebaseapp.com",
    databaseURL: "https://retaskd-cb23e-default-rtdb.europe-west1.firebasedatabase.app",
    projectId: "retaskd-cb23e",
    storageBucket: "retaskd-cb23e.appspot.com",
    messagingSenderId: "733187092963",
    appId: "1:733187092963:web:a76ff70ccfdb243860b0d6",
    measurementId: "G-KQ2CZS83MR",
  ),
};

Map l = {};
late AnimationController menuController;
late AnimationController fabController;
late Animation<double> animation;
//bool manuallyChangedLanguage = false;

late String primary;
late String background;

BoxDecoration bd = const BoxDecoration();
GridPaper gp = const GridPaper();
PageController wPageController = PageController();
ValueNotifier<int> pageSelected = ValueNotifier(0);

int currentNotePage = 0;
List<QuillController> controllers = [];

ValueNotifier<String> shownTop = ValueNotifier('none');

Note noteN = Note(createdTime: DateTime.now());

final ValueNotifier<ThemeData> themeNotifier = ValueNotifier(ThemeData());
final ValueNotifier<PageController> notePageController = ValueNotifier(PageController());

late StreamSubscription taskStream;
late StreamSubscription noteStream;

List<Note> notes = [];
List<Note> archivedNotes = [];
List<Note> unarchivedNotes = [];
List<Note> deletedNotes = [];

ValueNotifier<Map<String, List<Task>>> tasksLists = ValueNotifier(<String, List<Task>>{});
ValueNotifier<Map<String, List<Note>>> noteTags = ValueNotifier(<String, List<Note>>{});
ValueNotifier<Map<String, List<Note>>> archivedNoteTags = ValueNotifier(<String, List<Note>>{});

List<Task> tasks = [];
List<Task> deletedTasks = [];
List<Task> pendingTasks = [];
List<Task> thisWeek = [];

List<String> tagsUnincluded = [];
List<String> colorsUnincluded = [];

List<String> tagsUnincluded2 = [];
List<String> colorsUnincluded2 = [];

List<int> listsNotIncluded = [];
List<int> listsNotIncluded2 = [];

ValueNotifier<String> selectedColor = ValueNotifier('White');

ValueNotifier<List<Task>> shownList = ValueNotifier(pendingTasks);
ValueNotifier<List<Note>> shownTag = ValueNotifier(unarchivedNotes);

ValueNotifier<List<Note>> shownArchivedTag = ValueNotifier(archivedNotes);

ValueNotifier<List> recordings = ValueNotifier([]);

late SharedPreferences prefs;

final Map<String, String> languages = {
  'sr': 'Serbian',
  'en': 'English',
  'ru': 'Russian',
  'it': 'Italian',
  'ar': 'Arabic',
  'sl': 'Slovenian',
  'pl': 'Polish',
  //'fr': 'French',
  'es': 'Spanish',
  'de': 'German',
  'pt': 'Portuguese',
  'zh-cn': 'Chinese',
};

class Setting {
  final String title, trailing;
  final IconData icon;
  final Color? iconColor;
  final void Function(BuildContext) onTap;

  const Setting(this.title, this.icon, this.trailing, this.onTap, {this.iconColor});
}
