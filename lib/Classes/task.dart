import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:retaskd/data.dart';

class Task {
  String? id;
  String color;
  String tag;
  int notif;
  bool isDeleted;
  String title;
  List<String> list;
  int repeat;
  int priority;
  String description;
  DateTime due;

  Task({
    this.id,
    required this.color,
    required this.tag,
    required this.notif,
    required this.isDeleted,
    required this.title,
    required this.list,
    required this.repeat,
    required this.description,
    required this.due,
    this.priority = 3,
  });

  Task copy({
    String? id,
    String? color,
    String? tag,
    int? notif,
    int? repeat,
    bool? isDeleted,
    String? title,
    List<String>? list,
    String? description,
    DateTime? due,
    int? priority,
  }) =>
      Task(
        id: id ?? this.id,
        color: color ?? this.color,
        tag: tag ?? this.tag,
        notif: notif ?? this.notif,
        isDeleted: isDeleted ?? this.isDeleted,
        repeat: repeat ?? this.repeat,
        title: title ?? this.title,
        list: list ?? this.list,
        description: description ?? this.description,
        priority: priority ?? this.priority,
        due: due ?? this.due,
      );

  static Task fromJson(Map json) {
    //print(json['title']+'tRead');
    List<String> tagsovi = [];
    for (int i = 0; i < json['list'].length; i++) {
      tagsovi.add(json['list'][i]);
    }
    return Task(
      id: json['id'],
      color: json['color'] ?? 'White',
      tag: json['tag'] ?? '',
      notif: json['notif'] ?? -2,
      repeat: json['repeat'] ?? 0,
      isDeleted: json['isDeleted'] ?? false,
      title: json['title'] ?? ' ',
      list: tagsovi,
      priority: json['priority'] ?? 3,
      description: json['description'] ?? '',
      due: DateTime.parse(json['due'] ?? DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'color': color,
        'tag': tag,
        'notif': notif,
        'title': title,
        'list': list,
        'repeat': repeat,
        'isDeleted': isDeleted,
        'description': description,
        'priority': priority,
        'due': due.toIso8601String(),
      };

  void upload() {
    FirebaseFirestore.instance.collection('users').doc(user.uid).collection('tasks').add(toJson());
    //  print(title+'Tupload');
  }

  void update() {
    FirebaseFirestore.instance.collection('users').doc(user.uid).collection('tasks').doc(id!).update(toJson());
    //  print(title+'Tupdate');
  }

  void delete() {
    FirebaseFirestore.instance.collection('users').doc(user.uid).collection('tasks').doc(id!).delete();
    //  print(title+'Tdelete');
  }

  void sort() {
    FirebaseFirestore.instance.collection('users').doc(user.uid).collection('sort').doc('task').set({' ': taskIDs});
  }
}
