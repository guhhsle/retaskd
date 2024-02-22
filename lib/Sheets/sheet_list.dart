import 'package:retaskd/Classes/task.dart';
import 'package:flutter/material.dart';
import 'package:retaskd/Sheets/task_sheet.dart';
import 'package:retaskd/data.dart';

class SheetTaskList extends StatefulWidget {
  final String listName;

  const SheetTaskList({
    Key? key,
    required this.listName,
  }) : super(key: key);

  @override
  SheetTaskListState createState() => SheetTaskListState();
}

class SheetTaskListState extends State<SheetTaskList> {
  late String listName;
  @override
  void initState() {
    listName = widget.listName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
      stream: streamTask.snapshots(),
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
                  child: ValueListenableBuilder<Map<String, List<Task>>>(
                    valueListenable: tasksLists,
                    builder: (context, data, child) {
                      return Column(
                        children: [
                          data.isNotEmpty && data[listName]!.isNotEmpty
                              ? TextFormField(
                                  autofocus: false,
                                  initialValue: listName,
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
                                    String oldListName = listName;
                                    listName = title;
                                    for (var i = 0; i < data[oldListName]!.length; i++) {
                                      List<String> tags = data[oldListName]![i].list;
                                      tags[tags.indexOf(oldListName)] = title;
                                      data[oldListName]![i].copy(list: tags);
                                      data[oldListName]![i].update();
                                    }
                                    Map<String, List<Task>> map = Map<String, List<Task>>.from(data);
                                    map.remove(oldListName);
                                    tasksLists.value = map;
                                  },
                                )
                              : Container(),
                          Expanded(
                            child: ListView.builder(
                              controller: controller,
                              scrollDirection: Axis.vertical,
                              itemCount: data.isNotEmpty ? data[listName]!.length : 0,
                              itemBuilder: (context, index) {
                                Task task = data[listName]![index];
                                return ListTile(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      backgroundColor: Colors.transparent,
                                      isScrollControlled: true,
                                      builder: (context) {
                                        return TaskSheet(task: task, i: 0);
                                      },
                                    );
                                  },
                                  title: Text(
                                    task.title,
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
                                        onPressed: () {
                                          List<String> prevList = task.list;
                                          prevList.remove(listName);
                                          task.copy(list: prevList).update();
                                        },
                                        tooltip: l['Remove from list'],
                                        icon: const Icon(
                                          Icons.remove_circle_outline_rounded,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          task.delete();
                                        },
                                        tooltip: l['Delete task'],
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
