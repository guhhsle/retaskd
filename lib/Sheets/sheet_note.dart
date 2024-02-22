import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:retaskd/Classes/note.dart';
import 'package:retaskd/Page/note.dart';
import 'package:retaskd/data.dart';

import '../Widgets/custom_card.dart';
import '../theme/colors.dart';

class NoteBottomSheet extends StatefulWidget {
  final Note bottomSheetNote;
  const NoteBottomSheet({Key? key, required this.bottomSheetNote}) : super(key: key);
  @override
  NoteBottomSheetState createState() => NoteBottomSheetState();
}

class NoteBottomSheetState extends State<NoteBottomSheet> {
  late List<String> noteTagsNames2;

  @override
  void initState() {
    noteTagsNames2 = noteTags.value.keys.toList();

    for (var i = 0; i < archivedNoteTags.value.length; i++) {
      if (!noteTagsNames2.contains(archivedNoteTags.value.keys.elementAt(i))) {
        noteTagsNames2.add(archivedNoteTags.value.keys.elementAt(i));
      }
    }
    noteN = widget.bottomSheetNote;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
      stream: streamNote.snapshots(),
      builder: (context, snapshot) {
        return Card(
          margin: const EdgeInsets.all(8),
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          color: Theme.of(context).bottomSheetTheme.backgroundColor!.withOpacity(0.9),
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            children: [
              CustomCard(
                title: noteN.title,
                margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Icon(
                  Icons.subdirectory_arrow_right_outlined,
                  color: Theme.of(context).colorScheme.background,
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => AddEditNotePage(note: noteN)),
                  );
                },
              ),
              SizedBox(
                height: noteTagsNames2.isNotEmpty ? 48 : 0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: noteTagsNames2.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(left: index == 0 ? 16 : 8),
                      child: InputChip(
                        checkmarkColor: Theme.of(context).navigationBarTheme.backgroundColor,
                        onPressed: () {
                          setState(() {
                            if (noteN.tag.contains(noteTagsNames2[index])) {
                              noteN.tag.remove(noteTagsNames2[index]);
                            } else {
                              noteN.tag.add(noteTagsNames2[index]);
                            }
                          });
                          noteN.copy(tag: noteN.tag).update();
                        },
                        selected: noteN.tag.contains(noteTagsNames2[index]),
                        label: Text(
                          noteTagsNames2[index],
                          style: TextStyle(
                            color: noteN.tag.contains(noteTagsNames2[index])
                                ? Theme.of(context).navigationBarTheme.backgroundColor
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              ListTile(
                onTap: () {
                  noteN.isImportant = !noteN.isImportant;
                  noteN.update();
                },
                leading: Icon(
                  noteN.isImportant ? Icons.bookmark : Icons.bookmark_outline,
                ),
                title: Text(
                  l['Archive'],
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
              ListTile(
                onTap: () {
                  Note(
                    isImportant: noteN.isImportant,
                    isDeleted: noteN.isDeleted,
                    color: noteN.color,
                    title: noteN.title,
                    description: noteN.description,
                    tag: noteN.tag,
                    createdTime: DateTime.now(),
                  ).upload();
                  Navigator.of(context).pop();
                },
                leading: const Icon(Icons.copy_rounded),
                title: Text(
                  l['Duplicate'],
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: '${noteN.title}   ${quill.Document.fromJson(
                        json.decode(noteN.description),
                      ).toPlainText()}',
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).primaryColor,
                      content: Text(
                        l["Copied to clipboard"],
                        style: TextStyle(
                          color: Theme.of(context).navigationBarTheme.backgroundColor,
                        ),
                      ),
                      duration: const Duration(milliseconds: 512),
                    ),
                  );
                  Navigator.of(context).pop();
                },
                leading: const Icon(Icons.copy_all_rounded),
                title: Text(
                  l['Clipboard'],
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
              ListTile(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: '${user.uid}/${noteN.id}',
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).navigationBarTheme.backgroundColor,
                      content: Text(
                        l['Copied to clipboard'],
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      duration: const Duration(milliseconds: 500),
                    ),
                  );
                  Navigator.of(context).pop();
                },
                leading: const Icon(Icons.share_rounded),
                title: Text(
                  l['Share'],
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
              ListTile(
                onTap: () async {
                  setState(() {
                    noteN.isDeleted = !noteN.isDeleted;
                    noteN.update();
                  });
                  Navigator.of(context).pop();
                },
                leading: Icon(noteN.isDeleted ? Icons.delete : Icons.delete_outline),
                title: Text(
                  noteN.isDeleted ? l['Undo'] : l['Trash'],
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
              Container(
                height: 48,
                padding: const EdgeInsets.only(left: 16),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return ChoiceChip(
                      selected: noteN.color == lightColors.keys.elementAt(index),
                      label: const Text(""),
                      backgroundColor: lightColors.values.elementAt(index),
                      avatar: CircleAvatar(
                        backgroundColor: lightColors.values.elementAt(index),
                      ),
                      onSelected: (value) {
                        noteN.color = lightColors.keys.elementAt(index);
                        noteN.update();
                        setState(() {});
                      },
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(width: 4);
                  },
                  itemCount: lightColors.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
