import 'package:flutter/material.dart';
import 'package:retaskd/Settings/account.dart';
import 'package:retaskd/Settings/audio.dart';
import 'package:retaskd/Settings/interface.dart';
import 'package:retaskd/Settings/notes.dart';
import 'package:retaskd/Settings/tasks.dart';
import 'package:retaskd/Sheets/sheet_model.dart';
import 'package:retaskd/Widgets/sheet_scroll_model.dart';

import '../Settings/more.dart';
import '../Widgets/body.dart';
import '../data.dart';
import '../theme/colors.dart';

class PageSettings extends StatelessWidget {
  const PageSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<Map<String, IconData>, List<Setting>> map = {
      {l['More']: Icons.format_textdirection_l_to_r_rounded}: moreSet(),
      {'Interface': Icons.toggle_on_rounded}: interfaceSet(),
      {l['Tasks']: Icons.done_rounded}: tasksSet(),
      {l['Notes']: Icons.edit_outlined}: notesSet(),
      {l['Recordings']: Icons.multitrack_audio_rounded}: audioSet(),
      {l['Account']: Icons.account_circle_rounded}: accSet(),
      {'Primary': Icons.colorize_rounded}: themeMap(true),
      {'Background': Icons.tonality_rounded}: themeMap(false),
    };
    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16),
        child: FloatingActionButton(
          onPressed: () {},
          tooltip: ':P',
          child: const Icon(Icons.format_textdirection_l_to_r_rounded),
        ),
      ),
      appBar: AppBar(title: Text(l['Settings'])),
      body: Body(
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(top: 20, bottom: 82),
          itemCount: map.length,
          itemBuilder: (context, i) {
            return ListTile(
              title: Text(map.keys.elementAt(i).keys.first),
              leading: Icon(map.keys.elementAt(i).values.first),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (context) {
                    if (i < 6) {
                      return SheetModel(
                        list: map.values.elementAt(i),
                      );
                    } else {
                      return SheetScrollModel(
                        list: map.values.elementAt(i),
                      );
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
