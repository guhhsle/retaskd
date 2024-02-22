import 'package:flutter/material.dart';
import 'package:retaskd/Classes/task.dart';
import 'package:retaskd/Functions/task_functions.dart';
import 'package:retaskd/data.dart';

import '../theme/colors.dart';

class SheetAddTask extends StatefulWidget {
  const SheetAddTask({Key? key}) : super(key: key);

  @override
  State<SheetAddTask> createState() => _SheetAddTaskState();
}

class _SheetAddTaskState extends State<SheetAddTask> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _taskTagController = TextEditingController();
  DateTime _dateTime = DateTime.now();
  TimeOfDay _timeOfDay = TimeOfDay.now();
  String taskColor = pf['taskColor'];
  String taskTag = 'None';
  int notif = {
    'None': -2,
    'Morning': -1,
    'Custom': 0,
  }[pf['notifications']]!;
  int hours = 0, minutes = 0;
  List<String> taskList = [];
  int repeat = 0;
  bool showRepeat = false;
  List<String> repeats = [];

  String shown = pf['notifications'] == 'Custom' ? 'customNotif' : ' ';

  @override
  void initState() {
    int i = tasksLists.value.values.toList().indexOf(shownList.value);
    if (i >= 0) taskList.add(tasksLists.value.keys.elementAt(i));
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 150),
      child: Padding(
        padding: MediaQuery.of(context).viewInsets + const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 48,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                children: [
                  IconButton(
                    tooltip: l['Event'],
                    onPressed: () {
                      pickDate();
                      setState(() {
                        showRepeat = true;
                      });
                    },
                    icon: const Icon(Icons.event_rounded),
                  ),
                  showRepeat
                      ? IconButton(
                          onPressed: () {
                            swap('repeat');
                          },
                          icon: const Icon(Icons.repeat),
                        )
                      : Container(),
                  IconButton(
                    tooltip: l['Color'],
                    onPressed: () {
                      swap('color');
                    },
                    icon: Icon(
                      Icons.invert_colors_rounded,
                      color: lightColors[taskColor],
                    ),
                  ),
                  IconButton(
                    tooltip: l['Description'],
                    onPressed: () {
                      swap('description');
                    },
                    icon: const Icon(Icons.short_text_rounded),
                  ),
                  IconButton(
                    tooltip: {
                          -2: l["Don't notify"],
                          -1: l['Notify in the morning'],
                        }[notif] ??
                        l['Notify in advance'],
                    icon: Icon(
                      {
                            -2: Icons.notifications_off_rounded,
                            -1: Icons.notifications_none_rounded,
                          }[notif] ??
                          Icons.notifications_active_rounded,
                    ),
                    onPressed: () {
                      notif = {-2: -1, -1: 0}[notif] ?? -2;
                      swap(notif == 0 ? 'customNotif' : ' ');
                    },
                  ),
                  IconButton(
                    tooltip: l['Tag'],
                    onPressed: () {
                      swap('tag');
                    },
                    icon: Icon(icons[taskTag]),
                  ),
                  ValueListenableBuilder<Map<String, List<Task>>>(
                    valueListenable: tasksLists,
                    builder: (context, data, child) {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: data.length + 1,
                        itemBuilder: (context, index) {
                          if (index < data.length) {
                            String listName = data.keys.elementAt(index);
                            return Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: InputChip(
                                onPressed: () {
                                  setState(() {
                                    if (taskList.contains(listName)) {
                                      taskList.remove(listName);
                                    } else {
                                      taskList.add(listName);
                                    }
                                  });
                                },
                                selected: taskList.contains(listName),
                                label: Text(
                                  data.keys.elementAt(index),
                                  style: TextStyle(
                                    color: taskList.contains(listName)
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
                                tooltip: l['Add new list'],
                                onPressed: () {
                                  swap('newList');
                                },
                                selected: shown == 'newList',
                                showCheckmark: false,
                                label: Icon(
                                  Icons.add,
                                  color: shown == 'newList'
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
                        selected: taskColor == lightColors.keys.elementAt(index),
                        label: const Text(""),
                        backgroundColor: lightColors.values.elementAt(index),
                        avatar: CircleAvatar(
                          backgroundColor: lightColors.values.elementAt(index),
                        ),
                        onSelected: (value) {
                          taskColor = lightColors.keys.elementAt(index);
                          swap(' ');
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
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: l['Description']),
                ),
                'newList': Row(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: 8,
                          right: 32,
                        ),
                        child: TextFormField(
                          onFieldSubmitted: (value) {
                            setState(() {
                              Map<String, List<Task>> map = Map<String, List<Task>>.from(tasksLists.value);
                              map.addAll({value: []});
                              taskList.add(value);
                              tasksLists.value = map;
                              swap(' ');
                            });
                          },
                          autofocus: true,
                          style: Theme.of(context).textTheme.bodyLarge,
                          controller: _taskTagController,
                          decoration: InputDecoration(
                            labelText: l['New list'],
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            Map<String, List<Task>> map = Map<String, List<Task>>.from(tasksLists.value);
                            map.addAll({_taskTagController.text: []});
                            taskList.add(_taskTagController.text);
                            tasksLists.value = map;
                            swap(' ');
                          });
                        },
                        child: Text(l['New list']),
                      ),
                    )
                  ],
                ),
                'tag': SizedBox(
                  height: 48,
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return ChoiceChip(
                        onSelected: (value) {
                          taskTag = icons.keys.elementAt(index);
                          swap(' ');
                        },
                        selected: taskTag == icons.keys.elementAt(index),
                        label: Icon(
                          icons.values.elementAt(index),
                          color: taskTag == icons.keys.elementAt(index)
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).primaryColor,
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(width: 4);
                    },
                    itemCount: icons.length,
                  ),
                ),
                'customNotif': Row(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 0),
                        child: TextFormField(
                          initialValue: 0.toString(),
                          onChanged: (title) => setState(
                            () => hours = int.parse(title),
                          ),
                          keyboardType: TextInputType.number,
                          style: Theme.of(context).textTheme.bodyLarge,
                          autofocus: false,
                          decoration: InputDecoration(
                            labelText: l['Hours before event'],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Flexible(
                      child: TextFormField(
                        onChanged: (title) => setState(
                          () => minutes = int.parse(title),
                        ),
                        keyboardType: TextInputType.number,
                        style: Theme.of(context).textTheme.bodyLarge,
                        autofocus: false,
                        initialValue: 0.toString(),
                        decoration: InputDecoration(
                          labelText: l['Minutes before event'],
                        ),
                      ),
                    ),
                  ],
                ),
                'repeat': Row(
                  children: [
                    Flexible(
                      child: TextFormField(
                        onChanged: (title) => setState(
                          () => repeat = int.parse(title),
                        ),
                        keyboardType: TextInputType.number,
                        style: Theme.of(context).textTheme.bodyLarge,
                        autofocus: false,
                        initialValue: repeat.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Repeat', //Prevod
                        ),
                      ),
                    ),
                    IconButton(onPressed: () {}, icon: const Text('Day'))
                  ],
                ),
                ' ': Container()
              }[shown]!,
            ),
            Row(
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 16, bottom: 8),
                    child: TextFormField(
                      autofocus: true,
                      style: Theme.of(context).textTheme.bodyLarge,
                      controller: _nameController,
                      decoration: InputDecoration(labelText: l['Title']),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Task(
                      color: taskColor,
                      repeat: repeat,
                      tag: taskTag,
                      list: taskList,
                      notif: notif < 0 ? notif : (hours * 60 + minutes),
                      isDeleted: false,
                      title: _nameController.text,
                      description: _descriptionController.text,
                      due: DateTime(
                        _dateTime.year,
                        _dateTime.month,
                        _dateTime.day,
                        _timeOfDay.hour,
                        _timeOfDay.minute,
                      ),
                    ).upload();
                    if (taskList.isNotEmpty) {
                      shownList.value = tasksLists.value[taskList[0]]!;
                      parentTaskFolder.value = taskList[0];
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    l['Add'],
                    style: TextStyle(
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void swap(String bol) {
    setState(() {
      if (shown == bol) {
        shown = ' ';
      } else {
        shown = bol;
      }
    });
  }

  void pickDate() {
    FocusScope.of(context).unfocus();
    showTimePicker(
            builder: (context, child2) {
              return child2!;
            },
            initialEntryMode: TimePickerEntryMode.dial,
            context: context,
            initialTime: TimeOfDay.now())
        .then((date) {
      setState(() {
        _timeOfDay = date!;
      });
    });
    showDatePicker(
            builder: (context, child2) {
              return child2!;
            },
            context: context,
            initialDate: _dateTime,
            firstDate: DateTime(DateTime.now().year - 1),
            lastDate: DateTime(DateTime.now().year + 5))
        .then((date) {
      setState(() {
        _dateTime = date!;
      });
    });
  }
}
