import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:retaskd/Classes/note.dart';
import 'package:retaskd/Sheets/sheet_page_note.dart';
import 'package:retaskd/data.dart';

import '../theme/colors.dart';

class FloatingNote extends StatefulWidget {
  final String? shared;
  const FloatingNote({Key? key, this.shared}) : super(key: key);

  @override
  FloatingNoteState createState() => FloatingNoteState();
}

class FloatingNoteState extends State<FloatingNote> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Note>(
      valueListenable: noteNote,
      builder: (context, data, child) {
        return Card(
          elevation: 4,
          shadowColor: lightColors[noteN.color],
          margin: const EdgeInsets.only(left: 32, bottom: 16),
          color: lightColors[noteN.color],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: IconButton(
                    tooltip: l['Menu'],
                    icon: Icon(
                      Icons.menu,
                      color: Colors.grey.shade900,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) {
                          return const SheetPageNote();
                        },
                      );
                    },
                  ),
                ),
                IconButton(
                  tooltip: l['Archive'],
                  icon: Icon(
                    noteN.isImportant ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                    color: Colors.grey.shade900,
                  ),
                  onPressed: () {
                    noteN.isImportant = !noteN.isImportant;
                    noteN.update(link: widget.shared);
                    setState(() {});
                  },
                ),
                IconButton(
                  tooltip: l['Move to trash'],
                  icon: Icon(
                    noteN.isDeleted ? Icons.delete_rounded : Icons.delete_outline_rounded,
                    color: Colors.grey.shade900,
                  ),
                  onPressed: () {
                    noteN.isDeleted = !noteN.isDeleted;
                    noteN.update(link: widget.shared);
                    setState(() {});
                  },
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: IconButton(
                        tooltip: l['Save changes'],
                        icon: Icon(Icons.done_rounded, color: Colors.grey.shade900),
                        onPressed: () async {
                          noteN
                              .copy(description: jsonEncode(controllers[currentNotePage].document.toDelta().toJson()))
                              .update(link: widget.shared);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
