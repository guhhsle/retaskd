import 'package:flutter/material.dart';
import 'package:retaskd/Classes/note.dart';
import 'package:retaskd/Services/dialog_pass.dart';
import 'package:retaskd/data.dart';
import 'package:retaskd/functions.dart';

import '../Widgets/body.dart';
import '../Widgets/custom_gridview.dart';
import '../Widgets/custom_note_list.dart';

class PageArchived extends StatelessWidget {
  const PageArchived({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool bottom = pf['chipPosition'] == 'Bottom';
    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: pf['actionPosition'] != 'Top'
          ? Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: bottom ? 40 : 16,
                top: 16,
              ),
              child: FloatingActionButton(
                tooltip: l['Add security'],
                child: Icon(
                  {
                        '': Icons.lock_open_rounded,
                        'biometricsBiometrics': Icons.fingerprint_rounded,
                      }[pf['title']] ??
                      Icons.lock,
                ),
                onPressed: () {
                  showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (BuildContext context) {
                      return const DialogChangePass();
                    },
                  );
                },
              ),
            )
          : null,
      floatingActionButtonLocation: pf['actionPosition'] == 'End'
          ? FloatingActionButtonLocation.endFloat
          : FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: Text(l['Archive']),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: pf['actionPosition'] == 'Top'
                ? IconButton(
                    tooltip: l['Add security'],
                    icon: Icon(
                      {
                            '': Icons.lock_open_rounded,
                            'biometricsBiometrics': Icons.fingerprint_rounded,
                          }[pf['title']] ??
                          Icons.lock,
                    ),
                    onPressed: () {
                      showDialog(
                        barrierDismissible: true,
                        context: context,
                        builder: (BuildContext context) {
                          return const DialogChangePass();
                        },
                      );
                    },
                  )
                : Container(),
          )
        ],
      ),
      body: StreamBuilder(
        stream: streamNote.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: RefreshProgressIndicator(
                color: Colors.red,
              ),
            );
          } else {
            return ValueListenableBuilder<List<Note>>(
              valueListenable: shownArchivedTag,
              builder: (context, data, child) {
                return Body(
                  child: RefreshIndicator(
                    onRefresh: sync,
                    child: archivedNotes.isNotEmpty || archivedNoteTags.value.isNotEmpty
                        ? (bottom
                            ? Column(
                                children: [
                                  const SizedBox(
                                    height: 24,
                                  ),
                                  pf['grid'] ? CustomGridView(rawNoteList: data) : CustomNoteList(rawNoteList: data),
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: chipTags(context, true),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: chipTags(context, true),
                                  ),
                                  pf['grid'] ? CustomGridView(rawNoteList: data) : CustomNoteList(rawNoteList: data),
                                ],
                              ))
                        : Stack(
                            children: [
                              Center(
                                child: Icon(
                                  Icons.notes_rounded,
                                  color: Theme.of(context).primaryColor.withOpacity(0.4),
                                  size: 84,
                                ),
                              ),
                              ListView(),
                            ],
                          ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
