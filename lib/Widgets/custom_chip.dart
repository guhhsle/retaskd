import 'package:flutter/material.dart';

class CustomChip extends StatefulWidget {
  final void Function(bool value) onSelected;
  final void Function() onLongPress;
  final bool selected;
  final String label;

  const CustomChip({
    Key? key,
    required this.onSelected,
    required this.onLongPress,
    required this.selected,
    required this.label,
  }) : super(key: key);

  @override
  State<CustomChip> createState() => _CustomChipState();
}

class _CustomChipState extends State<CustomChip> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 8,
        bottom: 8,
      ),
      child: InkWell(
        onLongPress: widget.onLongPress,
        child: InputChip(
          selected: widget.selected,
          onSelected: widget.onSelected,
          label: Text(
            widget.label,
            style: TextStyle(
              color: widget.selected ? Theme.of(context).colorScheme.background : Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
