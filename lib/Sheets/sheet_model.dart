import 'package:flutter/material.dart';

import '../Widgets/custom_card.dart';
import '../data.dart';
import '../functions.dart';

class SheetModel extends StatefulWidget {
  final List<Setting> list;

  const SheetModel({Key? key, required this.list}) : super(key: key);

  @override
  State<SheetModel> createState() => _SheetModelState();
}

class _SheetModelState extends State<SheetModel> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      color: Theme.of(context).colorScheme.background.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            CustomCard(
              title: widget.list.first.title,
              onTap: () => widget.list.first.onTap(context),
              margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child:
                  widget.list.first.trailing != '' ? Text(t(widget.list.first.trailing)) : Icon(widget.list.first.icon),
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.list.length - 1,
              itemBuilder: (context, index) {
                int i = index + 1;
                return ListTile(
                  leading: Icon(widget.list[i].icon),
                  title: Text(t(widget.list[i].title)),
                  trailing: Text(t(widget.list[i].trailing)),
                  onTap: () => setState(() => widget.list[i].onTap(context)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
