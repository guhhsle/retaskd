import 'package:flutter/material.dart';

import '../Classes/item_note.dart';
import '../Classes/note.dart';
import '../Functions/note_functions.dart';
import '../Functions/task_functions.dart';
import '../Page/note.dart';
import '../Sheets/sheet_folder.dart';
import '../Sheets/sheet_note.dart';
import '../data.dart';
import 'custom_chip.dart';
import 'home.dart';

class CustomNoteList extends StatelessWidget {
  final List<Note> rawNoteList;
  const CustomNoteList({Key? key, required this.rawNoteList}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    bool bottom = pf['chipPosition'] == 'Bottom';
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.only(
          bottom: pf['actionPosition'] == 'Top' || bottom ? 16 : 80,
        ),
        itemCount: rawNoteList.length,
        scrollDirection: Axis.vertical,
        reverse: pf['reverseList'],
        itemBuilder: (context, index) {
          final note = rawNoteList[index];
          return InkWell(
            key: Key('$index'),
            child: NoteCardWidget(
              note: note,
              index: index,
              grid: false,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => AddEditNotePage(note: note)),
              );
            },
            onLongPress: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) {
                  return NoteBottomSheet(
                    bottomSheetNote: note,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

Container chipTags(BuildContext context, bool a) {
  List names = (a ? archivedNoteTags : noteTags).value.keys.toList();
  bool bottom = pf['chipPosition'] == 'Bottom';
  bool e = pf['actionPosition'] == 'Extended';
  double q = bottom ? 1 : 0;
  double w = bottom ? 0 : 1;
  return Container(
    height: a
        ? (names.isEmpty
            ? 24 * w
            : bottom
                ? 82
                : 64)
        : names.isEmpty
            ? 24 * w
            : e
                ? 64 * (1 + q)
                : 64 + 18 * q,
    padding: EdgeInsets.only(
      left: 16,
      right: 16,
      top: bottom ? 0 : 16,
      bottom: !a ? (e ? 82 * q : 4) : 0,
    ),
    child: ValueListenableBuilder<String>(
      valueListenable: a ? archivedParentNoteFolder : parentNoteFolder,
      builder: (context, parent, child) {
        return ListView(
          scrollDirection: Axis.horizontal,
          reverse: bottom,
          physics: const BouncingScrollPhysics(),
          children: [
            parent != ''
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 8, right: 8),
                    child: Chip(
                      deleteIcon: Text(
                        '/',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.background,
                        ),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                      onDeleted: () {
                        if (a) {
                          shownArchivedTag.value = archivedNoteTags.value[parentOfFolder(parent)] ?? archivedNotes;
                          archivedParentNoteFolder.value = parentOfFolder(parent);
                        } else {
                          shownTag.value = noteTags.value[parentOfFolder(parent)] ?? unarchivedNotes;
                          parentNoteFolder.value = parentOfFolder(parent);
                        }
                      },
                      label: AnimatedText(
                        text: parent,
                        speed: const Duration(milliseconds: 64),
                        style: TextStyle(color: Theme.of(context).colorScheme.background),
                        key: ValueKey(parent),
                      ),
                    ),
                  )
                : Container(),
            ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: (a ? relativeArchivedNoteFolders() : relativeNoteFolders()).keys.length,
              reverse: bottom,
              itemBuilder: (context, index) {
                String shortName = (a ? relativeArchivedNoteFolders() : relativeNoteFolders()).keys.elementAt(index);
                String fullName = (a ? relativeArchivedNoteFolders() : relativeNoteFolders()).values.elementAt(index);
                return CustomChip(
                  key: Key(
                    '${a}Note${(a ? relativeArchivedNoteFolders() : relativeNoteFolders()).values.elementAt(index)}',
                  ),
                  onLongPress: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return SheetNoteGroup(
                          a: a,
                          tagName: fullName,
                        );
                      },
                    );
                  },
                  onSelected: (value) {
                    if (a) {
                      if (relativeArchivedNoteFolders(prnt: fullName).isNotEmpty) {
                        shownArchivedTag.value = archivedNoteTags.value[fullName] ?? archivedNotes;
                        archivedParentNoteFolder.value = fullName;
                      } else if (shownArchivedTag.value == archivedNoteTags.value[fullName]) {
                        shownArchivedTag.value = archivedNoteTags.value[parentOfFolder(fullName)] ?? archivedNotes;
                      } else {
                        shownArchivedTag.value = archivedNoteTags.value[fullName] ?? archivedNotes;
                      }
                    } else {
                      if (relativeNoteFolders(prnt: fullName).isNotEmpty) {
                        shownTag.value = noteTags.value[fullName] ?? unarchivedNotes;
                        parentNoteFolder.value = fullName;
                      } else if (shownTag.value == noteTags.value[fullName]) {
                        shownTag.value = noteTags.value[parentOfFolder(fullName)] ?? unarchivedNotes;
                      } else {
                        shownTag.value = noteTags.value[fullName] ?? unarchivedNotes;
                      }
                    }
                  },
                  selected:
                      (a ? shownArchivedTag : shownTag).value == (a ? archivedNoteTags : noteTags).value[fullName],
                  label: shortName,
                );
              },
            ),
          ],
        );
      },
    ),
  );
}
