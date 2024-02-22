import 'package:flutter/material.dart';
import 'package:retaskd/data.dart';
import 'package:retaskd/functions.dart';

class Body extends StatelessWidget {
  final Widget child;
  final bool search;
  const Body({Key? key, required this.child, this.search = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool transparent = pf['appbar'] == 'Transparent' && !search;
    return Stack(
      children: [
        transparent ? box() : Container(),
        SafeArea(
          child: Container(
            color: Theme.of(context).appBarTheme.backgroundColor,
            width: double.infinity,
            height: 20,
          ),
        ),
        SafeArea(
          child: Card(
            color: transparent ? Colors.transparent : Theme.of(context).scaffoldBackgroundColor,
            margin: EdgeInsets.zero,
            shadowColor: Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Stack(
              children: [transparent ? Container() : box(), child],
            ),
          ),
        )
      ],
    );
  }
}
