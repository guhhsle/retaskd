// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:retaskd/Classes/note.dart';
import 'package:retaskd/Classes/task.dart';
import 'package:retaskd/Page/note.dart';
import 'package:retaskd/Services/dialog_pass.dart';
import 'package:retaskd/Services/local_auth.dart';
import 'package:retaskd/Sheets/sheet_note.dart';
import 'package:retaskd/Sheets/task_sheet.dart';
import 'package:retaskd/data.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:retaskd/functions.dart';

import '../theme/colors.dart';
import 'body.dart';
import 'custom_chip.dart';

class Delegate extends SearchDelegate {
  @override
  Widget? buildLeading(BuildContext context) {
    return query.isEmpty
        ? IconButton(
            onPressed: () {
              close(context, null);
            },
            icon: const Icon(Icons.arrow_back),
          )
        : IconButton(
            onPressed: () {
              query = '';
            },
            icon: const Icon(Icons.clear_rounded),
          );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [];
  }

  @override
  Widget buildResults(BuildContext context) {
    return SuggestionList(
      query: query,
      key: Key(query),
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.apply(
          bodyColor: pf['appbar'] == 'Transparent'
              ? Theme.of(context).colorScheme.background
              : textColor(Theme.of(context).primaryColor, Theme.of(context).colorScheme.background),
          decoration: TextDecoration.none,
        );
    final selectionTheme = Theme.of(context).textSelectionTheme.copyWith(
          cursorColor: pf['appbar'] == 'Transparent'
              ? Theme.of(context).colorScheme.background
              : textColor(
                  Theme.of(context).primaryColor,
                  Theme.of(context).colorScheme.background,
                ),
        );

    return Theme.of(context).copyWith(
      textTheme: textTheme,
      hintColor: Colors.transparent,
      inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
      appBarTheme: AppBarTheme(
        shadowColor: Colors.transparent,
        backgroundColor: pf['appbar'] == 'Black' ? Colors.black : Theme.of(context).primaryColor,
        foregroundColor: pf['appbar'] == 'Transparent'
            ? Theme.of(context).colorScheme.background
            : textColor(Theme.of(context).primaryColor, Theme.of(context).colorScheme.background),
      ),
      textSelectionTheme: selectionTheme,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return SuggestionList(
      query: query,
      key: Key(query),
    );
  }
}

class SuggestionList extends StatefulWidget {
  final String query;
  const SuggestionList({Key? key, required this.query}) : super(key: key);

  @override
  State<SuggestionList> createState() => _SuggestionListState();
}

class _SuggestionListState extends State<SuggestionList> {
  List suggestions = [];
  late String query;
  bool showArchive = false;
  bool showTrash = false;
  @override
  void initState() {
    query = widget.query;

    super.initState();
  }

  void refreshSuggestions() {
    suggestions.clear();

    for (var i = 0; i < tasks.length; i++) {
      if (tasks[i].title.toLowerCase().contains(query.toLowerCase()) ||
          tasks[i].description.toLowerCase().contains(query.toLowerCase()) ||
          tasks[i].list.map((str) => str.toLowerCase()).toList().contains(query.toLowerCase())) {
        suggestions.add(tasks[i]);
      }
    }
    for (var i = 0; i < notes.length; i++) {
      if ((!notes[i].isDeleted || showTrash) &&
              (!notes[i].isImportant || notes[i].isDeleted || showArchive) &&
              (notes[i].title.toLowerCase().contains(query.toLowerCase()) ||
                  quill.Document.fromJson(
                    json.decode(notes[i].description),
                  ).toPlainText().toLowerCase().contains(query.toLowerCase())) ||
          notes[i].tag.map((str) => str.toLowerCase()).toList().contains(query.toLowerCase())) {
        suggestions.add(notes[i]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: streamTask.snapshots(),
      builder: (context, snapTasks) {
        return StreamBuilder(
          stream: streamNote.snapshots(),
          builder: (context, snapNote) {
            if (snapTasks.hasError || snapNote.hasError) {
              return const Center(
                child: RefreshProgressIndicator(
                  color: Colors.red,
                ),
              );
            } else {
              refreshSuggestions();
              return Theme(
                data: Theme.of(context),
                child: Body(
                  search: true,
                  child: RefreshIndicator(
                    onRefresh: () async => setState(() => refreshSuggestions()),
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Container(
                            height: 64,
                            padding: const EdgeInsets.only(top: 16),
                            child: Row(
                              children: [
                                CustomChip(
                                  onSelected: (value) async {
                                    if (value) {
                                      if (pf['title'] == '') {
                                        setState(() => showArchive = true);
                                      } else if (pf['title'] == 'biometricsBiometrics') {
                                        final isAuthenticated = await LocalAuthApi.authenticate();
                                        if (isAuthenticated) {
                                          setState(() => showArchive = true);
                                        }
                                      } else {
                                        showDialog(
                                          barrierDismissible: true,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return DialogPass(
                                              onDone: () {
                                                setState(() => showArchive = true);
                                              },
                                            );
                                          },
                                        );
                                      }
                                    } else {
                                      setState(() {
                                        showArchive = false;
                                      });
                                    }
                                  },
                                  onLongPress: () {},
                                  selected: showArchive,
                                  label: l['Archive'],
                                ),
                                CustomChip(
                                  onSelected: (value) {
                                    setState(() => showTrash = !showTrash);
                                  },
                                  onLongPress: () {},
                                  selected: showTrash,
                                  label: l['Trash'],
                                ),
                                CustomChip(
                                  onSelected: (value) async {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return Padding(
                                          padding: MediaQuery.of(context).viewInsets + const EdgeInsets.all(16),
                                          child: TextFormField(
                                            autofocus: true,
                                            style: TextStyle(
                                              color: Theme.of(context).primaryColor,
                                            ),
                                            cursorColor: Theme.of(context).primaryColor,
                                            onFieldSubmitted: (newValue) async {
                                              try {
                                                String uid = '';
                                                bool u = true;
                                                String noteId = '';
                                                for (var i = 0; i < newValue.length; i++) {
                                                  if (newValue[i] == '/') {
                                                    u = false;
                                                    continue;
                                                  } else {
                                                    if (u) {
                                                      uid += newValue[i];
                                                    } else {
                                                      noteId += newValue[i];
                                                    }
                                                  }
                                                }
                                                await FirebaseFirestore.instance.enableNetwork();
                                                DocumentSnapshot snap = await FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(uid)
                                                    .collection('notes')
                                                    .doc(noteId)
                                                    .get();
                                                Note note = Note.fromJson(snap.data() as Map);
                                                await FirebaseFirestore.instance.disableNetwork();
                                                await Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) => AddEditNotePage(
                                                      note: note,
                                                      shared: '$uid/$noteId',
                                                    ),
                                                  ),
                                                );
                                              } catch (e) {
                                                customCrashDialog('Invalid link', () {}, context);
                                              }
                                            },
                                            decoration: InputDecoration(
                                              labelText: l['Share'],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  onLongPress: () {},
                                  selected: false,
                                  label: l['Share'],
                                ),
                              ],
                            ),
                          ),
                        ),
                        ListView.builder(
                          itemCount: suggestions.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: ((context, index) {
                            return ListTile(
                              title: Text(
                                suggestions[index].title,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              leading: Icon(
                                (suggestions[index] is Task) ? Icons.add : Icons.edit_outlined,
                              ),
                              trailing: ChoiceChip(
                                  selected: false,
                                  label: suggestions[index] is Task && suggestions[index].tag != 'None'
                                      ? Icon(icons[suggestions[index].tag])
                                      : const Text(""),
                                  backgroundColor: lightColors[suggestions[index].color],
                                  avatar: CircleAvatar(
                                    backgroundColor: lightColors[suggestions[index].color],
                                  ),
                                  shape: StadiumBorder(
                                    side: BorderSide(color: darkColors[suggestions[index].color]!, width: 2),
                                  ),
                                  onSelected: (value) {
                                    setState(() {});
                                  }),
                              onLongPress: () {
                                if (suggestions[index] is Note) {
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.transparent,
                                    isScrollControlled: true,
                                    builder: (context) {
                                      return NoteBottomSheet(
                                        bottomSheetNote: suggestions[index],
                                      );
                                    },
                                  );
                                }
                              },
                              onTap: () {
                                if (suggestions[index] is Task) {
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.transparent,
                                    isScrollControlled: true,
                                    builder: (context) {
                                      return TaskSheet(task: suggestions[index], i: 0);
                                    },
                                  );
                                } else {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => AddEditNotePage(
                                        note: suggestions[index],
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}
