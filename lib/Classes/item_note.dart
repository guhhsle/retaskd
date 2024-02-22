import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:retaskd/Classes/note.dart';
import 'package:retaskd/data.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import '../theme/colors.dart';

class NoteCardWidget extends StatelessWidget {
  const NoteCardWidget({Key? key, required this.note, required this.index, required this.grid}) : super(key: key);

  final Note note;
  final int index;
  final bool grid;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.yMMMd().format(note.createdTime);
    final minHeight = grid ? getMinHeight(index) : 64.0;
    final Color primary = pf['noteAdaptive'] == 'Transparent'
        ? Colors.transparent
        : pf['noteAdaptive'] == 'Custom'
            ? lightColors[note.color]!
            : Theme.of(context).primaryColor.withOpacity(0.6);
    final Color secondary = pf['noteAdaptive'] == 'Transparent'
        ? Theme.of(context).primaryColor
        : pf['noteAdaptive'] == 'Custom'
            ? darkColors[note.color]!
            : Theme.of(context).colorScheme.background;

    return Card(
      elevation: 4,
      shadowColor: pf['noteAdaptive'] == 'Transparent' ? Colors.transparent : Theme.of(context).primaryColor,
      margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: secondary,
          width: 2,
        ),
      ),
      color: primary,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Container(
          constraints: BoxConstraints(minHeight: minHeight),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: TextStyle(
                  color: secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 6),
              Hero(
                tag: note,
                child: DefaultTextStyle(
                  style: TextStyle(
                    fontFamily: pf['font'],
                    color: pf['noteAdaptive'] == 'Custom' ? Colors.grey.shade900 : secondary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  child: Text(
                    note.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Text(
                quill.Document.fromJson(json.decode(note.description)).toPlainText(),
                maxLines: grid ? 2 : 4,
                style: TextStyle(
                  color: secondary,
                  fontSize: 16,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  double getMinHeight(int index) =>
      <int, double>{
        0: 150,
        1: 200,
        2: 300,
      }[index % 4] ??
      150;
}
