import 'package:retaskd/Classes/note.dart';
import 'package:retaskd/Page/note.dart';
import 'package:retaskd/Sheets/sheet_note.dart';
import 'package:flutter/material.dart';
import 'package:retaskd/data.dart';

class SheetNoteGroup extends StatefulWidget {
  final String tagName;
  final bool a;

  const SheetNoteGroup({Key? key, required this.tagName, required this.a}) : super(key: key);

  @override
  SheetNoteGroupState createState() => SheetNoteGroupState();
}

class SheetNoteGroupState extends State<SheetNoteGroup> {
  late String tagName;
  @override
  void initState() {
    tagName = widget.tagName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
      stream: streamNote.snapshots(),
      builder: (context, snapshot) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: Colors.transparent,
            child: DraggableScrollableSheet(
              initialChildSize: 0.4,
              minChildSize: 0.2,
              maxChildSize: 0.75,
              builder: (_, controller) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).navigationBarTheme.backgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  padding: MediaQuery.of(context).viewInsets + const EdgeInsets.all(16),
                  child: ValueListenableBuilder<Map<String, List<Note>>>(
                    valueListenable: widget.a ? archivedNoteTags : noteTags,
                    builder: (context, data, child) {
                      return Column(
                        children: [
                          data.isNotEmpty && data[tagName]!.isNotEmpty
                              ? TextFormField(
                                  autofocus: false,
                                  initialValue: tagName,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: l['Tag...'],
                                    hintStyle: const TextStyle(color: Colors.grey),
                                  ),
                                  onFieldSubmitted: (title) async {
                                    String oldTagName = tagName;
                                    tagName = title;
                                    for (var i = 0; i < data[oldTagName]!.length; i++) {
                                      List<String> tags = data[oldTagName]![i].tag;
                                      tags[tags.indexOf(oldTagName)] = title;
                                      data[oldTagName]![i].copy(tag: tags);
                                      data[oldTagName]![i].update();
                                    }
                                    Map<String, List<Note>> map = Map<String, List<Note>>.from(data);
                                    map.remove(oldTagName);
                                    (widget.a ? archivedNoteTags : noteTags).value = map;
                                  },
                                )
                              : Container(),
                          Expanded(
                            child: ListView.builder(
                              controller: controller,
                              scrollDirection: Axis.vertical,
                              itemCount: data.isNotEmpty ? data[tagName]!.length : 0,
                              itemBuilder: (context, index) {
                                Note note = data[tagName]![index];
                                return ListTile(
                                  onTap: () async {
                                    Navigator.of(context).pop();
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => AddEditNotePage(note: note),
                                      ),
                                    );
                                  },
                                  onLongPress: () {
                                    showModalBottomSheet(
                                      backgroundColor: Colors.transparent,
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context) {
                                        return NoteBottomSheet(
                                          bottomSheetNote: note,
                                        );
                                      },
                                    );
                                  },
                                  title: Text(
                                    note.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  trailing: ListView(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      IconButton(
                                        tooltip: l['Remove from directory'],
                                        onPressed: () async {
                                          List<String> prevList = note.tag;
                                          prevList.remove(tagName);
                                          note.copy(tag: prevList).update();
                                        },
                                        icon: const Icon(
                                          Icons.remove_circle_outline_rounded,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: l['Move to trash'],
                                        onPressed: () async {
                                          note.copy(isDeleted: true).update();
                                        },
                                        icon: const Icon(
                                          Icons.delete_forever_rounded,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
