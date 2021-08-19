import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'colorstrings.dart';
import 'strings.dart';

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

showAlertDialog(BuildContext context, String message, AlertClickCallBack alertClickCallBack) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return CupertinoAlertDialog(
          title: new Text("Alert!"),
          content: new Text(message),
          actions: <Widget>[
            new CupertinoDialogAction(
              child: new Text("Ok"),
              onPressed: () {
                Navigator.pop(context);
                alertClickCallBack.onClickAction();
              },
            )
          ],
        );
      });
}

abstract class AlertClickCallBack {
  void onClickAction();
}

Widget getDataListWidget(Map<String, String> dataMap) {
  var fieldContainers = getFieldContainer(dataMap);
  return Stack(children: <Widget>[
    Align(
        alignment: Alignment.topCenter,
        child: Padding(
            padding: EdgeInsets.fromLTRB(0, 8, 8, 8),
            child: Material(
                child: Text(
              Strings.DETAILS,
              textAlign: TextAlign.start,
              style: TextStyle(color: Colors.black, fontFamily: "SourceSansPro", fontSize: 18.0, fontStyle: FontStyle.normal),
            )))),
    Padding(
        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
          shrinkWrap: false,
          itemBuilder: (context, position) {
            return fieldContainers[position];
          },
          itemCount: fieldContainers.isNotEmpty ? fieldContainers.length : 0,
        ))
  ]);
}

List getFieldContainer(Map<String, String> dataMap) {
  var widgetList = [];
  dataMap.forEach((key, value) {
    widgetList.add(Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Padding(
          padding: EdgeInsets.fromLTRB(14, 8, 10, 8),
          child: Material(
              color: Colors.transparent,
              child: Text(
                key,
                textAlign: TextAlign.start,
                style: TextStyle(color: HexColor(ColorStrings.HEADING), fontFamily: "SourceSansPro", fontSize: 12.0, fontStyle: FontStyle.normal),
              ))),
      Padding(
          padding: EdgeInsets.fromLTRB(14, 8, 10, 8),
          child: Material(
              color: Colors.transparent,
              child: Text(
                value,
                textAlign: TextAlign.start,
                style: TextStyle(color: HexColor(ColorStrings.HEADING), fontFamily: "SourceSansPro", fontSize: 12.0, fontStyle: FontStyle.normal),
              ))),
      Divider(thickness: 1.0, color: const Color(0xff979797))
    ]));
  });

  return widgetList;
}
