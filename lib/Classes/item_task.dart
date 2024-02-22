import 'package:flutter/material.dart';
import 'package:retaskd/Classes/task.dart';
import 'package:retaskd/data.dart';

import '../theme/colors.dart';

class CustomTask extends StatelessWidget {
  final Task itemTask;
  const CustomTask({Key? key, required this.itemTask}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isChecked = itemTask.isDeleted;
    bool transparent = pf['taskAdaptive'] == 'Transparent';
    final Color primary = {
      'Transparent': Colors.transparent,
      'Custom': lightColors[itemTask.color]!,
      'Primary': Theme.of(context).primaryColor.withOpacity(0.6),
    }[pf['taskAdaptive']]!;

    final Color secondary = {
      'Transparent': Theme.of(context).colorScheme.primary,
      'Custom': darkColors[itemTask.color]!,
      'Primary': Theme.of(context).colorScheme.background
    }[pf['taskAdaptive']]!;

    Color getColor(Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) return secondary;
      return primary;
    }

    return StatefulBuilder(
      builder: (context, setState) {
        Checkbox checkbox() {
          return Checkbox(
            checkColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            fillColor: MaterialStateProperty.resolveWith(getColor),
            value: isChecked,
            onChanged: (bool? value) async {
              isChecked = value!;
              setState(() {});
              await Future.delayed(const Duration(milliseconds: 250));
              isChecked = itemTask.isDeleted;
              setState(() {});
              itemTask.copy(isDeleted: value).update();
            },
          );
        }

        return Card(
          elevation: 2,
          shadowColor: transparent ? Colors.transparent : Theme.of(context).primaryColor,
          color: primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: transparent ? Colors.transparent : secondary,
              width: 2,
            ),
          ),
          margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
          child: Container(
            padding: const EdgeInsets.all(2),
            child: Row(
              children: [
                pf['checkbox'] == 'Left' ? checkbox() : Container(),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: 16, left: pf['checkbox'] == 'Left' ? 0 : 16),
                    child: Text(
                      itemTask.title,
                      maxLines: 4,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis,
                        color: pf['taskAdaptive'] == 'Custom' ? Colors.grey.shade900 : secondary,
                      ),
                    ),
                  ),
                ),
                itemTask.notif != -2
                    ? Padding(
                        padding: EdgeInsets.only(right: itemTask.tag != 'None' ? 8 : 0),
                        child: Icon(
                          itemTask.notif == -1 ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                          size: 22,
                          color: secondary,
                        ),
                      )
                    : Container(),
                itemTask.tag != 'None' ? Icon(icons[itemTask.tag], color: secondary) : Container(),
                !(pf['checkbox'] == 'Left') ? checkbox() : Container(),
                SizedBox(width: pf['checkbox'] == 'Left' ? 16 : 0)
              ],
            ),
          ),
        );
      },
    );
  }
}
