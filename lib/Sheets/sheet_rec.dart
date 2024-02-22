// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:retaskd/Functions/audio_functions.dart';
import 'package:retaskd/data.dart';
import 'package:path/path.dart';
import 'package:retaskd/functions.dart';

import '../Widgets/custom_card.dart';

class SheetRec extends StatefulWidget {
  final int index;

  const SheetRec({Key? key, required this.index}) : super(key: key);

  @override
  SheetRecState createState() => SheetRecState();
}

class SheetRecState extends State<SheetRec> {
  bool _editName = false;
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).bottomSheetTheme.backgroundColor!.withOpacity(0.9),
      margin: const EdgeInsets.all(8),
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(8),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Container(
            padding: MediaQuery.of(context).viewInsets + const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                CustomCard(
                  margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  title: recordings.value.length > widget.index ? basename(recordings.value[widget.index].path) : '',
                  child: Icon(
                    Icons.subdirectory_arrow_right_outlined,
                    color: Theme.of(context).colorScheme.background,
                  ),
                  onTap: () async {
                    try {
                      await playFile(widget.index);
                      Navigator.of(context).pop();
                    } on Exception {
                      customCrashDialog(l['Rename the file'], () {}, context);
                    }
                  },
                ),
                _editName
                    ? Row(
                        children: [
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 32),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: TextFormField(
                                  autofocus: true,
                                  style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    counterStyle: TextStyle(color: Theme.of(context).primaryColor),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: IconButton(
                                onPressed: () {
                                  if (_nameController.text.contains(' ')) {
                                    customCrashDialog(
                                      l['Remove blank space'],
                                      () {},
                                      context,
                                    );
                                  } else if (recNames.contains('${_nameController.text}.m4a')) {
                                    customCrashDialog(
                                      l['Recording with same name already exists'],
                                      () {},
                                      context,
                                    );
                                  } else {
                                    changeFileNameOnly(recordings.value[widget.index], _nameController.text);
                                    refreshRecordings();
                                    Navigator.of(context).pop();
                                  }
                                },
                                icon: const Icon(Icons.check_rounded),
                              ),
                            ),
                          )
                        ],
                      )
                    : ListTile(
                        onTap: () {
                          _editName = true;
                          setState(() {});
                        },
                        leading: const Icon(Icons.edit_outlined),
                        title: Text(l['Rename']),
                      ),
                ListTile(
                  onTap: () async {
                    customCrashDialog("${l['Press again to delete']} ${basename(recordings.value[widget.index].path)}",
                        () async {
                      recordings.value[widget.index].delete();
                      refreshRecordings();
                      Navigator.of(context).pop();
                    }, context);
                  },
                  leading: const Icon(Icons.delete_forever_rounded),
                  title: Text(l['Delete']),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<File> changeFileNameOnly(File file, String newFileName) {
    var path = file.path;
    var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    var newPath = '${path.substring(0, lastSeparator + 1)}$newFileName.m4a';
    return file.rename(newPath);
  }
}
