import 'package:cloud_firestore/cloud_firestore.dart';

import '../data.dart';

class Note {
  String? id;
  bool isImportant;
  bool isDeleted;
  bool linked;
  String color;
  String title;
  String description;
  int priority;
  List<String> tag;
  DateTime createdTime;

  Note(
      {this.id,
      this.isImportant = false,
      this.isDeleted = false,
      this.linked = false,
      this.color = 'White',
      this.title = '',
      this.description = '\n',
      this.priority = 3,
      this.tag = const [],
      required this.createdTime});

  Note copy({
    String? id,
    bool? isImportant,
    bool? isDeleted,
    bool? linked,
    String? color,
    String? title,
    String? description,
    List<String>? tag,
    int? priority,
    DateTime? createdTime,
  }) =>
      Note(
        id: id ?? this.id,
        isImportant: isImportant ?? this.isImportant,
        isDeleted: isDeleted ?? this.isDeleted,
        color: color ?? this.color,
        title: title ?? this.title,
        linked: linked ?? this.linked,
        description: description ?? this.description,
        tag: tag ?? this.tag,
        priority: priority ?? this.priority,
        createdTime: createdTime ?? this.createdTime,
      );

  static Note fromJson(Map json) {
    //print(json['title']+'nRead');
    List<String> tagsovi = [];
    for (int i = 0; i < json['tag'].length; i++) {
      tagsovi.add(json['tag'][i]);
    }
    return Note(
      id: json['id'],
      isImportant: json['isImportant'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      color: json['color'] ?? 'White',
      title: json['title'] ?? '',
      linked: json['linked'] ?? false,
      description: json['description'] ?? '\n',
      tag: tagsovi,
      priority: json['priority'] ?? 3,
      createdTime: DateTime.parse(json['time']),
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'isImportant': isImportant,
        'isDeleted': isDeleted,
        'color': color,
        'linked': linked,
        'description': description,
        'tag': tag,
        'priority': priority,
        'time': createdTime.toIso8601String(),
      };

  void upload() {
    FirebaseFirestore.instance.collection('users').doc(user.uid).collection('notes').add(toJson());
  }

  void update({String? link}) async {
    if (link == null) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).collection('notes').doc(id!).update(toJson());
    } else {
      String uid = '';
      bool u = true;
      String noteId = '';
      for (var i = 0; i < link.length; i++) {
        if (link[i] == '/') {
          u = false;
          continue;
        } else {
          if (u) {
            uid += link[i];
          } else {
            noteId += link[i];
          }
        }
      }
      await FirebaseFirestore.instance.enableNetwork();
      FirebaseFirestore.instance.collection('users').doc(uid).collection('notes').doc(noteId).update(toJson());
      await FirebaseFirestore.instance.disableNetwork();
    }
  }

  void delete() {
    FirebaseFirestore.instance.collection('users').doc(user.uid).collection('notes').doc(id!).delete();
  }
}
