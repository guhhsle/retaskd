import 'package:flutter/material.dart';

import '../data.dart';
import '../functions.dart';
import 'custom_card.dart';

class SheetScrollModel extends StatefulWidget {
  final List<Setting> list;

  const SheetScrollModel({Key? key, required this.list}) : super(key: key);

  @override
  SheetScrollModelState createState() => SheetScrollModelState();
}

class SheetScrollModelState extends State<SheetScrollModel> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Colors.transparent,
        child: DraggableScrollableSheet(
          initialChildSize: 0.4,
          maxChildSize: 0.75,
          minChildSize: 0.2,
          builder: (_, controller) {
            return Card(
              margin: const EdgeInsets.all(8),
              color: Theme.of(context).colorScheme.background.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    CustomCard(
                      title: widget.list.first.title,
                      onTap: () {
                        widget.list.first.onTap(context);
                      },
                      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      child: widget.list.first.trailing != ''
                          ? Text(t(widget.list.first.trailing))
                          : Icon(widget.list.first.icon),
                    ),
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        controller: controller,
                        itemCount: widget.list.length - 1,
                        itemBuilder: (context, index) {
                          int i = index + 1;
                          return ListTile(
                            leading: Icon(
                              widget.list[i].icon,
                              color: widget.list[i].iconColor,
                            ),
                            title: Text(t(widget.list[i].title)),
                            trailing: Text(t(widget.list[i].trailing)),
                            onTap: () => setState(() => widget.list[i].onTap(context)),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
