import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:retaskd/Classes/note.dart';
import 'package:retaskd/Functions/note_functions.dart';
import 'package:retaskd/Services/floating_note.dart';
import 'package:retaskd/Sheets/sheet_page_note.dart';
import 'package:retaskd/data.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../functions.dart';
import '../theme/colors.dart';

class AddEditNotePage extends StatefulWidget {
  final Note note;
  final String? shared;

  const AddEditNotePage({Key? key, required this.note, this.shared}) : super(key: key);
  @override
  AddEditNotePageState createState() => AddEditNotePageState();
}

class AddEditNotePageState extends State<AddEditNotePage> {
  @override
  void initState() {
    noteN = widget.note;
    refreshNotePageView(widget.shared != null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool transparent = pf['appbar'] == 'Transparent';
    bool k = MediaQuery.of(context).viewInsets.bottom != 0;
    return WillPopScope(
      onWillPop: () {
        updateNote();
        return Future.value(true);
      },
      child: ValueListenableBuilder<Note>(
        valueListenable: noteNote,
        builder: (context, data, child) {
          return Scaffold(
            floatingActionButton: pf['actionPosition'] == 'Extended' && !k ? FloatingNote(shared: widget.shared) : null,
            floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              leading: IconButton(
                tooltip: l['Menu'],
                icon: const Icon(Icons.menu),
                onPressed: () {
                  noteN.description = jsonEncode(
                    controllers[currentNotePage].document.toDelta().toJson(),
                  );
                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return SheetPageNote(shared: widget.shared);
                    },
                  );
                },
              ),
              shadowColor: Colors.transparent,
              backgroundColor: transparent ? null : lightColors[noteN.color],
              foregroundColor: transparent ? null : Colors.black,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    tooltip: l['Save changes'],
                    onPressed: () {
                      updateNote();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.done_rounded),
                  ),
                ),
              ],
              title: Hero(
                tag: noteN,
                child: Material(
                  child: TextFormField(
                    maxLines: 1,
                    maxLength: 24,
                    key: Key(noteN.createdTime.toString()),
                    initialValue: noteN.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: transparent ? Theme.of(context).appBarTheme.foregroundColor : Colors.black,
                    ),
                    decoration: InputDecoration(
                      counterText: "",
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: l['Title'],
                    ),
                    validator: (title) => title != null && title.isEmpty ? l['The title cannot be empty'] : '',
                    onChanged: (title) => setState(() => noteN.title = title),
                  ),
                ),
              ),
            ),
            body: Stack(
              children: [
                transparent ? box() : Container(),
                SafeArea(
                  child: Container(
                    color: transparent ? Colors.transparent : lightColors[noteN.color],
                    width: double.infinity,
                    height: 20,
                  ),
                ),
                SafeArea(
                  child: Card(
                    color: transparent ? Colors.transparent : Theme.of(context).scaffoldBackgroundColor,
                    margin: EdgeInsets.zero,
                    shadowColor: Colors.transparent,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Stack(
                      children: [
                        transparent ? Container() : box(),
                        ValueListenableBuilder<PageController>(
                          valueListenable: notePageController,
                          builder: (context, data, child) {
                            return Column(
                              children: [
                                Expanded(
                                  child: PageView(
                                    key: Key('${data.initialPage}$nList$noteWidgets'),
                                    controller: data,
                                    physics: const BouncingScrollPhysics(),
                                    onPageChanged: (page) {
                                      currentNotePage = page;
                                      if (noteN.isDeleted) {
                                        noteN = deletedNotes[page];
                                      } else if (noteN.isImportant) {
                                        noteN = shownArchivedTag.value[page];
                                      } else {
                                        noteN = shownTag.value[page];
                                      }
                                      noteNote.value = noteN;
                                    },
                                    children: noteWidgets,
                                  ),
                                ),
                                k || kIsWeb
                                    ? QuillToolbar.basic(
                                        key: Key('${data.initialPage}$nList$noteWidgets'),
                                        controller: controllers[currentNotePage],
                                        multiRowsDisplay: false,
                                        toolbarIconSize: 20,
                                        locale: Locale(pf['locale']),
                                        //onImagePickCallback: (file) async {
                                        //  return file.path;
                                        //},
                                        //onVideoPickCallback: (file) async {
                                        //  return file.path;
                                        //},
                                      )
                                    : Container(),
                                Container(
                                  height: k || pf['actionPosition'] != 'Extended' ? 0 : 64,
                                )
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Future updateNote() async {
    noteN
        .copy(description: jsonEncode(controllers[currentNotePage].document.toDelta().toJson()))
        .update(link: widget.shared);
  }
}

class NoteTemplate extends StatelessWidget {
  final QuillController controller;
  const NoteTemplate({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QuillEditor(
      autoFocus: false,
      scrollPhysics: const BouncingScrollPhysics(),
      locale: Locale(pf['locale']),
      focusNode: FocusNode(),
      scrollable: true,
      scrollController: ScrollController(),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      controller: controller,
      expands: true,
      readOnly: false,
      onImagePaste: (imageBytes) async {
        return imageBytes.toString();
      },
    );
  }
}
