import 'package:flutter/material.dart';
import 'package:retaskd/Functions/note_functions.dart';
import 'package:retaskd/data.dart';

import '../Widgets/body.dart';
import '../Widgets/custom_gridview.dart';
import '../Widgets/custom_note_list.dart';
import '../functions.dart';

class PageTrash extends StatefulWidget {
  const PageTrash({Key? key}) : super(key: key);

  @override
  PageTrashState createState() => PageTrashState();
}

class PageTrashState extends State<PageTrash> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16),
        child: pf['actionPosition'] != 'Top'
            ? FloatingActionButton(
                tooltip: l['Undo everything'],
                child: const Icon(Icons.replay_rounded),
                onPressed: () {
                  customCrashDialog(
                    l['Press again to move all notes from the trash back to active workspace'],
                    undoDeletedNotes,
                    context,
                  );
                },
              )
            : null,
      ),
      floatingActionButtonLocation: pf['actionPosition'] == 'End'
          ? FloatingActionButtonLocation.endFloat
          : FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(actions: [
        pf['actionPosition'] == 'Top'
            ? IconButton(
                tooltip: l['Undo everything'],
                icon: const Icon(Icons.replay_rounded),
                onPressed: () {
                  customCrashDialog(
                    l['Press again to move all notes from the trash back to active workspace'],
                    undoDeletedNotes,
                    context,
                  );
                },
              )
            : Container(),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            tooltip: l['Delete all permanently'],
            icon: const Icon(Icons.delete_forever_rounded),
            onPressed: () {
              customCrashDialog(
                l['Press again to delete all notes from the trash permanently, this cannot be reversed'],
                deleteDeletedNotes,
                context,
              );
            },
          ),
        ),
      ], title: Text(l['Trash'])),
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
            return Body(
              child: RefreshIndicator(
                onRefresh: sync,
                child: deletedNotes.isEmpty
                    ? Stack(
                        children: [
                          Center(
                            child: Icon(
                              Icons.delete_outline_rounded,
                              color: Theme.of(context).primaryColor.withOpacity(0.4),
                              size: 84,
                            ),
                          ),
                          ListView(),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Column(
                          children: [
                            pf['grid']
                                ? CustomGridView(rawNoteList: deletedNotes)
                                : CustomNoteList(rawNoteList: deletedNotes),
                          ],
                        ),
                      ),
              ),
            );
          }
        },
      ),
    );
  }
}
