import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:retaskd/Functions/note_functions.dart';
import 'package:retaskd/Functions/task_functions.dart';
import 'package:retaskd/Page/viewer.dart';
import 'package:retaskd/Services/notif_controller.dart';
import 'package:retaskd/data.dart';
import 'package:retaskd/theme/colors.dart';
import 'package:retaskd/theme/theme.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';

import 'Page/page_log.dart';
import 'functions.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions[kIsWeb ? 'Web' : 'Android']);

  FirebaseFirestore.instance.settings = const Settings(
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  if (!kIsWeb) {
    await FirebaseFirestore.instance.disableNetwork();
  }

  await initPrefs();

  if (pf['firstBoot'] && !kIsWeb) {
    await FirebaseFirestore.instance.enableNetwork();
    await FirebaseAuth.instance.signInAnonymously();
    pf['recDirectory'] = '${(await getApplicationDocumentsDirectory()).path}/Recordings/';
    prefs.setString('recDirectory', pf['recDirectory']);
    await Directory(pf['recDirectory']).create();
  }
  user = FirebaseAuth.instance.currentUser!;
  noteStream = listenNotes(user);
  taskStream = listenTasks(user);
  runApp(
    MyApp(child: pf['firstBoot'] ? const PageMail() : const NotesPage()),
  );
}

class MyApp extends StatelessWidget {
  final Widget child;
  const MyApp({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      NotificationController.initializeLocalNotifications();
    }
    return ValueListenableBuilder<ThemeData>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, widget) {
        List<String> supportedLocales = [];
        for (int i = 0; i < languages.length; i++) {
          supportedLocales.add(languages.keys.elementAt(i));
        }
        supportedLocales.remove('zh-cn');
        return MaterialApp(
          locale: Locale(pf['locale'] == 'zh-cn' ? 'en' : pf['locale']),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            SfGlobalLocalizations.delegate,
          ],
          supportedLocales: [
            for (int i = 0; i < supportedLocales.length; i++) Locale(supportedLocales[i]),
          ],
          debugShowCheckedModeBanner: false,
          theme: themeData(
            tc: color(true, false),
            bc: color(false, false),
            dark: false,
          ),
          title: 'Taskd',
          home: child,
        );
      },
    );
  }
}
