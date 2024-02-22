import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:retaskd/Classes/task.dart';
import 'package:retaskd/data.dart';

import '../Widgets/custom_card.dart';
import '../theme/colors.dart';
import '../theme/theme.dart';

class TaskSheet extends StatefulWidget {
  final Task task;
  final int i;
  const TaskSheet({Key? key, required this.task, required this.i}) : super(key: key);

  @override
  TaskSheetState createState() => TaskSheetState();
}

class TaskSheetState extends State<TaskSheet> {
  late Task task;
  String selectedOption = ' ';

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeData(
        tc: darkColors[selectedColor.value]!,
        bc: lightColors[selectedColor.value]!,
        dark: false,
      ),
      child: Builder(
        builder: (context) {
          return Card(
            margin: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            shadowColor: Colors.transparent,
            color: Theme.of(context).colorScheme.background.withOpacity(0.9),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(8) + MediaQuery.of(context).viewInsets,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomCard(
                        margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        title: l['Save'],
                        child: Container(),
                        onTap: () {
                          task.update();
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_forever_rounded),
                      tooltip: l['Delete'],
                      onPressed: () {
                        task.delete();
                      },
                    ),
                  ],
                ),
                ListTile(
                  title: TextFormField(
                    initialValue: task.title,
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: InputDecoration(
                      counterText: "",
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: l['Title'],
                    ),
                    onChanged: (val) {
                      task.title = val;
                    },
                  ),
                ),
                ListTile(
                  title: TextFormField(
                    initialValue: task.description,
                    keyboardType: TextInputType.multiline,
                    style: Theme.of(context).textTheme.bodyLarge,
                    maxLines: null,
                    decoration: InputDecoration(
                      counterText: "",
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: l['Description'],
                    ),
                    onChanged: (val) {
                      task.description = val;
                    },
                  ),
                ),
                ListTile(
                  title: {
                    'tag': SizedBox(
                      height: 48,
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return ChoiceChip(
                            onSelected: (value) {
                              setState(() {
                                task.tag = icons.keys.elementAt(index);
                                selectedOption = '';
                              });
                            },
                            selected: task.tag == icons.keys.elementAt(index),
                            label: Icon(
                              icons.values.elementAt(index),
                              color: task.tag == icons.keys.elementAt(index)
                                  ? lightColors[selectedColor.value]!
                                  : darkColors[selectedColor.value]!,
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(
                            width: 4,
                          );
                        },
                        itemCount: icons.length,
                      ),
                    ),
                    'color': SizedBox(
                      height: 48,
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return ChoiceChip(
                            selectedColor: darkColors.values.elementAt(index),
                            selected: selectedColor.value == darkColors.keys.elementAt(index),
                            label: const Text(""),
                            backgroundColor: lightColors.values.elementAt(index),
                            avatar: CircleAvatar(
                              backgroundColor: lightColors.values.elementAt(index),
                            ),
                            onSelected: (value) {
                              changeNumber(lightColors.keys.elementAt(index));
                              selectedOption = ' ';
                              setState(() {});
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
                    'list': SizedBox(
                      height: tasksLists.value.isEmpty ? 0 : 48,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: tasksLists.value.length + 1,
                        itemBuilder: (context, index) {
                          String name = index == 0 ? l['Close'] : tasksLists.value.keys.elementAt(index - 1);
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: InputChip(
                              showCheckmark: index != 0,
                              onPressed: () {
                                setState(() {
                                  if (index == 0) {
                                    selectedOption = ' ';
                                  } else {
                                    if (task.list.contains(tasksLists.value.keys.elementAt(index - 1))) {
                                      task.list.remove(tasksLists.value.keys.elementAt(index - 1));
                                    } else {
                                      task.list.add(tasksLists.value.keys.elementAt(index - 1));
                                    }
                                    task.copy(tag: task.tag).update();
                                  }
                                });
                              },
                              selected: index == 0 || task.list.contains(name),
                              label: Text(
                                name.length > 1 ? name : ' $name ',
                                style: TextStyle(
                                  color: task.list.contains(name) || index == 0
                                      ? lightColors[selectedColor.value]!
                                      : darkColors[selectedColor.value]!,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    ' ': SizedBox(
                      height: 48,
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        children: [
                          ActionChip(
                            label: const Icon(Icons.invert_colors_rounded),
                            onPressed: () {
                              setState(() {
                                selectedOption = 'color';
                              });
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: ActionChip(
                              label: Icon(
                                icons[task.tag],
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedOption = 'tag';
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            height: 48,
                            child: ListView.builder(
                              itemCount: task.list.length,
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: ActionChip(
                                    label: Text(
                                      task.list[index].length > 1 ? task.list[index] : ' ${task.list[index]} ',
                                      style: TextStyle(color: Theme.of(context).primaryColor),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        selectedOption = 'list';
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          task.list.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: ActionChip(
                                    label: const Text('  '),
                                    onPressed: () {
                                      setState(() {
                                        selectedOption = 'list';
                                      });
                                    },
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    )
                  }[selectedOption]!,
                  onTap: () {
                    selectedOption = ' ';
                    setState(() {});
                  },
                ),
                ListTile(
                  leading: TextButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      showTimePicker(
                        builder: (context, child2) => child2!,
                        initialEntryMode: TimePickerEntryMode.dial,
                        context: context,
                        initialTime: TimeOfDay(hour: task.due.hour, minute: task.due.hour),
                      ).then((date) {
                        task.due = DateTime(
                          task.due.year,
                          task.due.month,
                          task.due.day,
                          date!.hour,
                          date.minute,
                        );
                        setState(() {});
                      });
                      showDatePicker(
                        builder: (context, child2) {
                          return child2!;
                        },
                        context: context,
                        initialDate: task.due,
                        firstDate: DateTime(task.due.year - 1),
                        lastDate: DateTime(task.due.year + 5),
                      ).then(
                        (date) {
                          setState(() {
                            task.due = date!;
                          });
                        },
                      );
                    },
                    child: Text(
                      DateFormat('dd-MM/kk:mm').format(
                        DateTime(
                          task.due.year,
                          task.due.month,
                          task.due.day,
                          task.due.hour,
                          task.due.minute,
                        ),
                      ),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  title: Text({
                        -2: l["Don't notify"],
                        -1: l["Notify in the morning"],
                      }[task.notif] ??
                      l["Notify in advance"]),
                  trailing: task.notif > -1
                      ? SizedBox(
                          width: 80,
                          child: TextFormField(
                            textAlign: TextAlign.end,
                            keyboardType: TextInputType.number,
                            initialValue: task.notif.toString(),
                            style: Theme.of(context).textTheme.bodyLarge,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              counterText: "",
                              suffixText: 'min',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              hintText: '0', //Prevod
                            ),
                            onChanged: (val) {
                              task.notif = int.tryParse(val) ?? 0;
                            },
                          ),
                        )
                      : null,
                  onTap: () {
                    task.notif = {-2: -1, -1: 0}[task.notif] ?? -2;
                    setState(() {});
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void changeNumber(String i) async {
    setState(() {
      task.color = i;
      selectedColor.value = i;
    });
  }

  @override
  void initState() {
    task = widget.task;
    selectedColor.value = widget.task.color;
    super.initState();
  }
}
