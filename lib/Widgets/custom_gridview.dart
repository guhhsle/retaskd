import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../Classes/item_note.dart';
import '../Classes/note.dart';
import '../Page/note.dart';
import '../Sheets/sheet_note.dart';
import '../data.dart';

class CustomGridView extends StatelessWidget {
  final List<Note> rawNoteList;
  const CustomGridView({Key? key, required this.rawNoteList}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    bool bottom = pf['chipPosition'] == 'Bottom';
    return Expanded(
      child: StaggeredGridView.countBuilder(
        padding: EdgeInsets.only(
          bottom: pf['actionPosition'] == 'Top' || bottom ? 16 : 80,
          left: 8,
          right: 8,
        ),
        reverse: pf['reverseList'],
        itemCount: rawNoteList.length,
        staggeredTileBuilder: (index) => const StaggeredTile.fit(2),
        crossAxisCount: 4,
        physics: const BouncingScrollPhysics(),
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        itemBuilder: (context, index) {
          final note = rawNoteList[index];
          return InkWell(
            child: NoteCardWidget(
              note: note,
              index: index,
              grid: true,
            ),
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddEditNotePage(note: note)));
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
