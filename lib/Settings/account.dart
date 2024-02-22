import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:retaskd/Services/google_sign_in.dart';

import '../Functions/note_functions.dart';
import '../Functions/task_functions.dart';
import '../Page/page_log.dart';
import '../data.dart';
import '../functions.dart';

List<Setting> accSet() {
  if (user.isAnonymous || user.email == null) {
    return [
      Setting(
        'No mail, sign in to backup',
        Icons.mail_outline_rounded,
        '',
        (c) async {
          await Navigator.push(
            c,
            MaterialPageRoute(
              builder: (context) => const PageMail(),
            ),
          );
        },
      ),
    ];
  } else {
    return [
      Setting(
        user.email ?? 'No mail, sign in to backup',
        Icons.mail_outline_rounded,
        '',
        (c) {
          showModalBottomSheet(
            context: c,
            backgroundColor: Theme.of(c).scaffoldBackgroundColor,
            builder: (context) {
              return Padding(
                padding: MediaQuery.of(context).viewInsets + const EdgeInsets.all(16),
                child: TextFormField(
                  autofocus: true,
                  style: Theme.of(context).textTheme.bodyLarge,
                  initialValue: user.email ?? '',
                  onFieldSubmitted: (newValue) {
                    user.updateEmail(newValue);
                    Navigator.of(context).pop();
                  },
                  decoration: InputDecoration(
                    labelText: l['Email'],
                  ),
                ),
              );
            },
          );
        },
      ),
      Setting(
        user.displayName ?? 'User',
        Icons.person_rounded,
        'Change',
        (c) {
          showModalBottomSheet(
            context: c,
            backgroundColor: Theme.of(c).scaffoldBackgroundColor,
            builder: (context) {
              return Padding(
                padding: MediaQuery.of(context).viewInsets + const EdgeInsets.all(16),
                child: TextFormField(
                  autofocus: true,
                  style: Theme.of(context).textTheme.bodyLarge,
                  initialValue: user.displayName ?? '',
                  onFieldSubmitted: (newValue) {
                    user.updateDisplayName(newValue);
                    Navigator.of(context).pop();
                  },
                  decoration: InputDecoration(
                    labelText: l['User'],
                  ),
                ),
              );
            },
          );
        },
      ),
      Setting(
        'Sync timeout',
        Icons.cloud_sync_rounded,
        'pf//syncTimeout',
        (c) => setPref('syncTimeout', (pf['syncTimeout'] + 2) % 20),
      ),
      Setting(
        'Change password',
        Icons.password_rounded,
        '',
        (c) => FirebaseService().resetPassword(user.email ?? ' ', c),
      ),
      Setting(
        'Log out',
        Icons.person_remove_rounded,
        '',
        (c) async {
          await FirebaseAuth.instance.signInAnonymously().then((result) {
            user = FirebaseAuth.instance.currentUser!;

            noteStream = listenNotes(user);
            taskStream = listenTasks(user);
          });
        },
      ),
      Setting(
        'Delete account',
        Icons.person_off_rounded,
        '',
        (c) async {
          customCrashDialog(
            l['Press to delete account, this cannot be reversed'],
            () async {
              user.delete();
              await FirebaseAuth.instance.signInAnonymously().then((result) {
                user = FirebaseAuth.instance.currentUser!;
                noteStream = listenNotes(user);
                taskStream = listenTasks(user);
              });
            },
            c,
          );
        },
      ),
    ];
  }
}
