import 'package:flutter/material.dart';
import 'package:retaskd/Classes/item_task.dart';
import 'package:retaskd/Classes/task.dart';
import 'package:retaskd/Sheets/task_sheet.dart';
import 'package:retaskd/data.dart';

import '../Widgets/chip_list.dart';
import '../functions.dart';

class Page1 extends StatelessWidget {
  const Page1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool bottom = pf['chipPosition'] == 'Bottom';
    return StreamBuilder(
      stream: streamTask.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: RefreshProgressIndicator(
              color: Colors.red,
            ),
          );
        } else {
          return ValueListenableBuilder<List<Task>>(
            valueListenable: shownList,
            builder: (context, data, child) {
              return RefreshIndicator(
                onRefresh: sync,
                child: tasks.isNotEmpty
                    ? (bottom
                        ? Column(
                            children: [
                              const SizedBox(
                                height: 24,
                              ),
                              CustomTaskList(contextTaskList: data),
                              chipList(context),
                            ],
                          )
                        : Column(
                            children: [
                              chipList(context),
                              CustomTaskList(contextTaskList: data),
                            ],
                          ))
                    : Stack(
                        children: [
                          Center(
                            child: Icon(
                              Icons.done_rounded,
                              color: Theme.of(context).primaryColor.withOpacity(0.4),
                              size: 84,
                            ),
                          ),
                          ListView(),
                        ],
                      ),
              );
            },
          );
        }
      },
    );
  }
}

class CustomTaskList extends StatelessWidget {
  final List<Task> contextTaskList;
  const CustomTaskList({Key? key, required this.contextTaskList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool bottom = pf['chipPosition'] == 'Bottom';
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.only(
          bottom: pf['actionPosition'] == 'Top' || bottom ? 16 : 80,
        ),
        reverse: pf['reverseList'],
        itemCount: contextTaskList.length,
        itemBuilder: (context, index) {
          final task = contextTaskList[index];
          return InkWell(
            key: Key(index.toString()),
            onTap: () async {
              showModalBottomSheet(
                elevation: 0,
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) {
                  return TaskSheet(task: task, i: 0);
                },
              );
            },
            child: CustomTask(itemTask: task),
          );
        },
      ),
    );
  }
}
