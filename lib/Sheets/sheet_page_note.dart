import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:retaskd/data.dart';
import 'package:retaskd/functions.dart';

import '../Widgets/custom_card.dart';
import '../theme/colors.dart';

class SheetPageNote extends StatelessWidget {
  final String? shared;
  const SheetPageNote({Key? key, this.shared}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> noteTagsNames2 = noteTags.value.keys.toList();

    for (var i = 0; i < archivedNoteTags.value.length; i++) {
      if (!noteTagsNames2.contains(archivedNoteTags.value.keys.elementAt(i))) {
        noteTagsNames2.add(archivedNoteTags.value.keys.elementAt(i));
      }
    }

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Card(
          shadowColor: Colors.transparent,
          margin: const EdgeInsets.all(8),
          color: Theme.of(context).bottomSheetTheme.backgroundColor!.withOpacity(0.9),
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
              CustomCard(
                margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                title: l['Delete permanently'],
                child: Icon(
                  Icons.delete_forever_rounded,
                  color: Theme.of(context).colorScheme.background,
                ),
                onTap: () {
                  customCrashDialog(
                    'Confirm', //Prevod
                    () {
                      noteN.delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Theme.of(context).navigationBarTheme.backgroundColor,
                          content: Text(
                            l['Note permanently deleted'],
                            style: TextStyle(color: Theme.of(context).primaryColor),
                          ),
                          duration: const Duration(seconds: 5),
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                    context,
                  );
                },
              ),
              ListTile(
                onTap: () {
                  noteN.isImportant = !noteN.isImportant;
                  noteNote.value = noteN;
                  noteN.update(link: shared);
                  setState(() {});
                },
                leading: Icon(noteN.isImportant ? Icons.bookmark : Icons.bookmark_outline),
                title: Text(l['Archive']),
              ),
              ListTile(
                onTap: () {
                  noteN.isDeleted = !noteN.isDeleted;
                  noteN.update(link: shared);
                  setState(() {});
                },
                leading: Icon(noteN.isDeleted ? Icons.delete : Icons.delete_outlined),
                title: Text(noteN.isDeleted ? l['Remove from trash'] : l['Move to trash']),
              ),
              ListTile(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: controllers[currentNotePage].document.toPlainText()));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).navigationBarTheme.backgroundColor,
                      content: Text(
                        l['Copied to clipboard'],
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      duration: const Duration(milliseconds: 500),
                    ),
                  );
                  Navigator.of(context).pop();
                },
                leading: const Icon(Icons.copy_all_rounded),
                title: Text(l['Clipboard']),
              ),
              ListTile(
                onTap: () {
                  if (shared == null) {
                    noteN.copy(linked: true).update(link: shared);
                    Clipboard.setData(
                      ClipboardData(
                        text: '${user.uid}/${noteN.id}',
                      ),
                    );
                  } else {
                    Clipboard.setData(
                      ClipboardData(
                        text: shared!,
                      ),
                    );
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).navigationBarTheme.backgroundColor,
                      content: Text(
                        l['Copied to clipboard'],
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      duration: const Duration(milliseconds: 500),
                    ),
                  );
                  Navigator.of(context).pop();
                },
                leading: const Icon(Icons.share_rounded),
                title: Text(l['Share']),
              ),
              SizedBox(
                height: noteTagsNames2.isEmpty ? 0 : 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: noteTagsNames2.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: InputChip(
                        onPressed: () {
                          if (noteN.tag.contains(noteTagsNames2[index])) {
                            noteN.tag.remove(noteTagsNames2[index]);
                          } else {
                            noteN.tag.add(noteTagsNames2[index]);
                          }
                          noteN.update(link: shared);
                          setState(() {});
                        },
                        selected: noteN.tag.contains(noteTagsNames2[index]),
                        label: Text(
                          noteTagsNames2[index],
                          style: TextStyle(
                            color: noteN.tag.contains(noteTagsNames2[index])
                                ? Theme.of(context).scaffoldBackgroundColor
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                height: 48,
                padding: const EdgeInsets.only(left: 16),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return ChoiceChip(
                      selected: noteN.color == lightColors.keys.elementAt(index),
                      label: const Text(""),
                      backgroundColor: lightColors.values.elementAt(index),
                      avatar: CircleAvatar(
                        backgroundColor: lightColors.values.elementAt(index),
                      ),
                      onSelected: (value) {
                        noteN.color = lightColors.keys.elementAt(index);
                        noteN.update(link: shared);
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
            ],
          ),
        );
      },
    );
  }
}
