import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:retaskd/Classes/note.dart';
import 'package:retaskd/Functions/task_functions.dart';
import 'package:retaskd/Page/note.dart';
import 'package:retaskd/data.dart';

import '../theme/colors.dart';

StreamSubscription<QuerySnapshot<Map<String, dynamic>>> listenNotes(User us) {
  streamNote = FirebaseFirestore.instance.collection('users').doc(us.uid).collection('notes');
  return streamNote.snapshots().listen(
    (data) {
      notes.clear();
      for (var i = 0; i < data.docs.length; i++) {
        Note note = Note.fromJson(data.docs[i].data());
        note.id = data.docs[i].id;
        notes.add(note);
      }
      refreshNotes();
    },
  );
}

List<Note> nList = [];

void refreshNotePageView(bool shared) {
  Note note = noteN.copy();
  notePageController.value.dispose();
  noteWidgets.clear();
  controllers.clear();
  if (shared) {
    controllers.add(
      QuillController(
        document: Document.fromJson(json.decode(note.description)),
        selection: const TextSelection.collapsed(offset: 0),
      ),
    );
    noteWidgets.add(
      NoteTemplate(
        controller: controllers[0],
      ),
    );
    currentNotePage = 0;
  } else {
    if (note.isDeleted) {
      nList = deletedNotes;
    } else if (note.isImportant) {
      if (note.tag.isEmpty) {
        shownArchivedTag.value = archivedNotes;
      } else if (shownArchivedTag.value != archivedNotes &&
          note.tag.contains(archivedNoteTags.value.keys
              .elementAt(archivedNoteTags.value.values.toList().indexOf(shownArchivedTag.value)))) {
      } else {
        shownArchivedTag.value = archivedNoteTags.value[note.tag[0]]!;
      }
      nList = shownArchivedTag.value;
    } else {
      if (note.tag.isEmpty) {
        shownTag.value = unarchivedNotes;
      } else if (shownTag.value != unarchivedNotes &&
          note.tag.contains(noteTags.value.keys.elementAt(noteTags.value.values.toList().indexOf(shownTag.value)))) {
      } else {
        shownTag.value = noteTags.value[note.tag[0]]!;
      }
      nList = shownTag.value;
    }
    for (var i = 0; i < nList.length; i++) {
      if (nList[i].id == note.id) {
        currentNotePage = i;
        noteN = nList[i];
      }
      controllers.add(
        QuillController(
          document: Document.fromJson(json.decode(nList[i].description)),
          selection: const TextSelection.collapsed(offset: 0),
        ),
      );
      noteWidgets.add(
        NoteTemplate(
          key: Key('${nList[i].id}'),
          controller: controllers[i],
        ),
      );
    }
  }

  notePageController.value = PageController(initialPage: currentNotePage);
  noteNote.value = noteN;
}

void refreshNotes() {
  archivedNotes.clear();
  unarchivedNotes.clear();
  deletedNotes.clear();
  Map<String, List<Note>> map = Map<String, List<Note>>.from(noteTags.value);
  Map<String, List<Note>> mapA = Map<String, List<Note>>.from(archivedNoteTags.value);
  for (var i = 0; i < map.length; i++) {
    map.values.elementAt(i).clear();
  }
  for (var i = 0; i < mapA.length; i++) {
    mapA.values.elementAt(i).clear();
  }
  notes.sort((a, b) {
    return {
      'Date, Asc': b.createdTime.compareTo(a.createdTime),
      'Date, Desc': a.createdTime.compareTo(b.createdTime),
      'Name, Asc': b.title.compareTo(a.title),
      'Name, Desc': a.title.compareTo(b.title),
      'Color, Asc': darkColors.keys.toList().indexOf(b.color).compareTo(darkColors.keys.toList().indexOf(a.color)),
      'Color, Desc': darkColors.keys.toList().indexOf(a.color).compareTo(darkColors.keys.toList().indexOf(b.color)),
    }[pf['sortNotes']]!;
  });

  for (int i = 0; i < notes.length; i++) {
    Note note = notes[i];
    if (!note.isDeleted) {
      for (int l = 0; l < note.tag.length; l++) {
        String prnt = note.tag[l];
        while (prnt != '') {
          if (note.isImportant && !mapA.containsKey(prnt)) {
            mapA.addAll({prnt: []});
          } else if (!note.isImportant && !map.containsKey(prnt)) {
            map.addAll({prnt: []});
          }
          prnt = parentOfFolder(prnt);
        }
      }
    }
  }

  for (int i = 0; i < notes.length; i++) {
    if (notes[i].isImportant && !notes[i].isDeleted) {
      for (var t = 0; t < notes[i].tag.length; t++) {
        mapA[notes[i].tag[t]]!.insert(0, notes[i]);
      }
      if (notes[i].tag.isEmpty) {
        archivedNotes.insert(0, notes[i]);
      }
    } else if (notes[i].isDeleted) {
      deletedNotes.insert(0, notes[i]);
    } else {
      for (var t = 0; t < notes[i].tag.length; t++) {
        map[notes[i].tag[t]]!.insert(0, notes[i]);
      }
      if (notes[i].tag.isEmpty) {
        unarchivedNotes.insert(0, notes[i]);
      }
    }
  }
  noteTags.value = map;
  archivedNoteTags.value = mapA;
  refreshNotePageView(false);
}

void undoDeletedNotes() {
  for (int i = 0; i < deletedNotes.length; i++) {
    deletedNotes[i].copy(isDeleted: false).update();
  }
}

void deleteDeletedNotes() {
  for (int i = 0; i < deletedNotes.length; i++) {
    deletedNotes[i].delete();
  }
}

ValueNotifier<String> parentNoteFolder = ValueNotifier('');
ValueNotifier<String> archivedParentNoteFolder = ValueNotifier('');

Map<String, String> relativeNoteFolders({String? prnt}) {
  prnt ??= parentNoteFolder.value;
  Map<String, String> map = <String, String>{};
  for (int i = 0; i < noteTags.value.length; i++) {
    String fullName = noteTags.value.keys.toList()[i];
    if (prnt == parentOfFolder(fullName)) {
      map[relativeNoteName(fullName, false)] = fullName;
    }
  }
  return map;
}

Map<String, String> relativeArchivedNoteFolders({String? prnt}) {
  prnt ??= archivedParentNoteFolder.value;
  Map<String, String> map = <String, String>{};
  for (int i = 0; i < archivedNoteTags.value.length; i++) {
    String fullName = archivedNoteTags.value.keys.toList()[i];
    if (prnt == parentOfFolder(fullName)) {
      map[relativeNoteName(fullName, true)] = fullName;
    }
  }
  return map;
}

String relativeNoteName(String fullName, bool a) {
  String newParent = fullName.replaceAll('${a ? archivedParentNoteFolder.value : parentNoteFolder.value}/', '');
  String finalName = '';
  for (int i = 0; i < newParent.length; i++) {
    if (newParent[i] == '/') break;
    finalName += newParent[i];
  }
  return finalName;
}
