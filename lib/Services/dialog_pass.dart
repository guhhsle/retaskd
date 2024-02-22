// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:retaskd/data.dart';

class DialogPass extends StatelessWidget {
  final void Function() onDone;
  const DialogPass({Key? key, required this.onDone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: TextFormField(
                      style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
                      autofocus: true,
                      onChanged: (title2) {
                        if (title2 == pf['title']) {
                          Navigator.of(context).pop();
                          onDone();
                        }
                      },
                      decoration: InputDecoration(
                        counterStyle: TextStyle(color: Theme.of(context).primaryColor),
                        prefixIcon: Icon(
                          Icons.lock_outline_rounded,
                          color: Theme.of(context).primaryColor,
                        ),
                        labelText: l['Password'],
                        labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class DialogChangePass extends StatefulWidget {
  const DialogChangePass({Key? key}) : super(key: key);

  @override
  DialogChangePassState createState() => DialogChangePassState();
}

class DialogChangePassState extends State<DialogChangePass> {
  bool none = false;
  bool biometrics = false;
  String pass = ' ';

  @override
  void initState() {
    super.initState();
    if (pf['title'] == '') {
      none = true;
    } else if (pf['title'] == 'biometricsBiometrics') {
      biometrics = true;
    } else {
      pass = pf['title'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 16, left: 8, right: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l['Set Password'],
                        style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Theme.of(context).primaryColor),
                      ),
                    )),
                Row(
                  children: [
                    InputChip(
                      selected: none,
                      label: Text(
                        l['None'],
                        style: TextStyle(
                          color: none ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onSelected: (bool value) async {
                        setState(() {
                          none = true;
                          biometrics = false;
                        });
                      },
                    ),
                    Container(
                      width: 16,
                    ),
                    InputChip(
                      selected: biometrics,
                      label: Text(
                        l['Fingerprint'],
                        style: TextStyle(
                          color:
                              biometrics ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onSelected: (bool value) async {
                        none = false;
                        biometrics = true;
                        setState(() {});
                      },
                    ),
                  ],
                ),
                Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 16),
                    child: TextFormField(
                      style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
                      autofocus: false,
                      onChanged: (title2) {
                        setState(() {
                          pass = title2;
                          none = false;
                          biometrics = false;
                        });
                      },
                      decoration: InputDecoration(
                        counterStyle: TextStyle(color: Theme.of(context).primaryColor),
                        prefixIcon: Icon(
                          Icons.lock_outlined,
                          color: Theme.of(context).primaryColor,
                        ),
                        labelText: l['Password'],
                        labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                        enabledBorder:
                            OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                        focusedBorder:
                            OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                      ),
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          l['Cancel'],
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        onPressed: () async {
                          if (none) {
                            prefs.setString('title', '');
                          } else if (biometrics) {
                            prefs.setString('title', 'biometricsBiometrics');
                          } else {
                            prefs.setString('title', pass);
                          }
                          pf['title'] = prefs.getString('title')!;
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          l['Confirm'],
                          style: TextStyle(
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
