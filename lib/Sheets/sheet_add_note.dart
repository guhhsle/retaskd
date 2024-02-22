import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:retaskd/Functions/note_functions.dart';

import '../Classes/note.dart';
import 'package:retaskd/data.dart';

import '../theme/colors.dart';

class SheetAddNote extends StatefulWidget {
  const SheetAddNote({Key? key}) : super(key: key);

  @override
  State<SheetAddNote> createState() => _SheetAddNoteState();
}

class _SheetAddNoteState extends State<SheetAddNote> {
  String noteNumber = pf['noteColor'];
  bool advanced = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _noteContentController = TextEditingController();
  final TextEditingController _noteTagController = TextEditingController();
  List<String> noteTag = <String>[];

  String shown = pf['notifications'] == 0 ? 'customNotif' : ' ';

  @override
  void initState() {
    int i = noteTags.value.values.toList().indexOf(shownTag.value);
    if (i >= 0) noteTag.add(noteTags.value.keys.elementAt(i));
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteContentController.dispose();
    noteN = Note(createdTime: DateTime.now());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 150),
      child: Padding(
        padding: MediaQuery.of(context).viewInsets + const EdgeInsets.all(8.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            height: 48,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              children: [
                IconButton(
                  tooltip: l['Color'],
                  onPressed: () {
                    swap('color');
                  },
                  icon: Icon(
                    Icons.invert_colors_rounded,
                    color: lightColors[noteNumber],
                  ),
                ),
                IconButton(
                  tooltip: l['Description'],
                  onPressed: () {
                    swap('description');
                  },
                  icon: const Icon(Icons.short_text_rounded),
                ),
                ValueListenableBuilder<Map>(
                  valueListenable: noteTags,
                  builder: (context, data, child) {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: data.length + 1,
                      itemBuilder: (context, index) {
                        if (index < data.length) {
                          String listName = data.keys.elementAt(index);
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: InputChip(
                              onPressed: () {
                                if (noteTag.contains(listName)) {
                                  noteTag.remove(listName);
                                } else {
                                  noteTag.add(listName);
                                }
                                setState(() {});
                              },
                              selected: noteTag.contains(listName),
                              label: Text(
                                noteTags.value.keys.elementAt(index),
                                style: TextStyle(
                                  color: noteTag.contains(listName)
                                      ? Theme.of(context).scaffoldBackgroundColor
                                      : Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: InputChip(
                              tooltip: l['Add new category'],
                              onPressed: () {
                                swap('newFolder');
                              },
                              selected: shown == 'newFolder',
                              showCheckmark: false,
                              label: Icon(
                                Icons.add,
                                color: shown == 'newFolder'
                                    ? Theme.of(context).scaffoldBackgroundColor
                                    : Theme.of(context).primaryColor,
                                size: 16,
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 0),
            child: {
              'color': SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return ChoiceChip(
                      selected: noteNumber == lightColors.keys.elementAt(index),
                      label: const Text(""),
                      backgroundColor: lightColors.values.elementAt(index),
                      avatar: CircleAvatar(
                        backgroundColor: lightColors.values.elementAt(index),
                      ),
                      onSelected: (value) {
                        setState(() {
                          noteNumber = lightColors.keys.elementAt(index);
                          swap(' ');
                        });
                      },
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(
                      width: 4,
                    );
                  },
                  itemCount: lightColors.length,
                ),
              ),
              'description': TextFormField(
                autofocus: true,
                style: Theme.of(context).textTheme.bodyLarge,
                controller: _noteContentController,
                decoration: InputDecoration(
                  labelText: l['Content'],
                ),
              ),
              'newFolder': Row(
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8, right: 32),
                      child: TextFormField(
                        onFieldSubmitted: (value) {
                          Map<String, List<Note>> map = Map<String, List<Note>>.from(noteTags.value);
                          map.addAll({value: []});
                          noteTag.add(value);
                          noteTags.value = map;
                          swap('');
                        },
                        autofocus: true,
                        style: Theme.of(context).textTheme.bodyLarge,
                        controller: _noteTagController,
                        decoration: InputDecoration(labelText: l['Category']),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        Map<String, List<Note>> map = Map<String, List<Note>>.from(noteTags.value);
                        map.addAll({_noteTagController.text: []});
                        noteTag.add(_noteTagController.text);
                        noteTags.value = map;
                        swap('');
                      },
                      child: Text(
                        l['New category'],
                        style: TextStyle(
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              ' ': Container()
            }[shown]!,
          ),
          Row(
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 32, bottom: 8),
                  child: TextFormField(
                    autofocus: true,
                    style: Theme.of(context).textTheme.bodyLarge,
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l['Title'],
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  final quill.Delta delta = quill.Delta()..insert('${_noteContentController.text}\n');
                  noteN = Note(
                    isImportant: false,
                    isDeleted: false,
                    color: noteNumber,
                    title: _nameController.text,
                    description: jsonEncode(delta.toJson()),
                    tag: noteTag,
                    createdTime: DateTime.now(),
                  );
                  noteN.upload();
                  if (noteTag.isNotEmpty) {
                    shownTag.value = noteTags.value[noteTag[0]]!;
                    parentNoteFolder.value = noteTag[0];
                  }
                  Navigator.of(context).pop();
                },
                child: Text(l['Add']),
              ),
            ],
          )
        ]),
      ),
    );
  }

  void swap(String bol) {
    if (shown == bol) {
      shown = ' ';
    } else {
      shown = bol;
    }
    setState(() {});
  }
}
