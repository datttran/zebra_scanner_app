import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Test extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        height: 20,
        color: CupertinoColors.black,
        child: Text(
          'hello',
          style: TextStyle(color: CupertinoColors.white),
        ),
      ),
    );
  }
}
