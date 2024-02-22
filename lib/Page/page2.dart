import 'package:flutter/material.dart';
import 'package:retaskd/Classes/note.dart';
import 'package:retaskd/data.dart';
import 'package:retaskd/functions.dart';

import '../Widgets/custom_gridview.dart';
import '../Widgets/custom_note_list.dart';

class Page2 extends StatelessWidget {
  const Page2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool bottom = pf['chipPosition'] == 'Bottom';
    return StreamBuilder(
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
            valueListenable: shownTag,
            builder: (context, data, child) {
              return RefreshIndicator(
                onRefresh: sync,
                child: ValueListenableBuilder<Map>(
                  valueListenable: noteTags,
                  builder: (context, data2, child) {
                    return unarchivedNotes.isNotEmpty || data2.isNotEmpty
                        ? (bottom
                            ? Column(
                                children: [
                                  const SizedBox(height: 24),
                                  pf['grid'] ? CustomGridView(rawNoteList: data) : CustomNoteList(rawNoteList: data),
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: chipTags(context, false),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Align(alignment: Alignment.topLeft, child: chipTags(context, false)),
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
                              ListView(physics: const BouncingScrollPhysics()),
                            ],
                          );
                  },
                ),
              );
            },
          );
        }
      },
    );
  }
}
