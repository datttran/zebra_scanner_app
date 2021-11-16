import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:zebra_trackaware/classes/order.dart';
import 'package:zebra_trackaware/constants.dart';
import 'package:zebra_trackaware/globals.dart' as globals;
import 'package:zebra_trackaware/logics/searchField.dart';
import 'package:zebra_trackaware/logics/string_extension.dart';
import 'package:zebra_trackaware/pages/tender.dart';
import 'package:zebra_trackaware/widget/card.dart';

import '../globals.dart';

String greeting() {
  var hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Morning';
  }
  if (hour < 17) {
    return 'Afternoon';
  }
  return 'Evening';
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isLoading = false;
  DataTable scannedTable = DataTable(
    key: UniqueKey(),
    columns: [
      DataColumn(
          label: Text(
            'Id',
            style: TextStyle(
              color: Color(0xff957be2),
            ),
          ),
          numeric: true),
      DataColumn(
          label: Text(
        'Barcode #',
        style: TextStyle(
          color: Color(0xff957be2),
        ),
      )),
      DataColumn(
          label: Text(
        'Strength',
        style: TextStyle(
          color: Color(0xff957be2),
        ),
      ))
    ],
    rows: [
      //DataRow(cells: [DataCell(Text('1')), DataCell(Text('')), DataCell(Text(''))])
    ],
  );
  static const EventChannel scanChannel = EventChannel('com.zebra_trackaware/scan');
  static const MethodChannel methodChannel = MethodChannel('com.zebra_trackaware/command');

  Widget table(barcode) {
    listTable = barcode.split('\n');
    List<String> temp = listTable.toSet().toList();
    globals.listTable = temp;
    List<Widget> entry = [];
    int i = 1;

    listTable.forEach((element) {
      entry.add(Row(
        children: [
          SizedBox(
            width: hP * 5.5,
          ),
          Text(
            i.toString(),
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(
            width: hP * 10,
          ),
          Text(
            element,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ));
      i = i + 1;
    });

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: hP * 5,
            ),
            Text(
              'Id',
              style: TextStyle(color: Color(0xff6038f6), fontSize: vP * 3),
            ),
            SizedBox(
              width: hP * 20,
            ),
            Text(
              'Barcode #',
              style: TextStyle(color: Color(0xff6038f6), fontSize: vP * 3),
            )
          ],
        ),
        Column(
          children: entry,
        )
      ],
    );
  }

  Future<void> _sendDataWedgeCommand(String command, String parameter) async {
    try {
      String argumentAsJson = "{\"command\":$command,\"parameter\":$parameter}";
      await methodChannel.invokeMethod('sendDataWedgeCommandStringParameter', argumentAsJson);
    } on PlatformException {
      //  Error invoking Android method
    }
  }

  Future<void> _createProfile(String profileName) async {
    try {
      await methodChannel.invokeMethod('createDataWedgeProfile', profileName);
    } on PlatformException {
      //  Error invoking Android method
    }
  }

  void _onEvent(event) {
    setState(() {
      Map barcodeScan = jsonDecode(event);

      scannedCode = barcodeScan['scanData'];
      scannedTable.rows.add(DataRow(cells: [DataCell(Text((scannedTable.rows.length + 1).toString())), DataCell(Text(globals.scannedCode)), DataCell(Text(''))]));
    });
  }

  void _onError(Object error) {
    setState(() {
      scannedCode = "Barcode: error";
    });
  }

  @override
  void initState() {
    getTodayTender();
    _createProfile("RFIDPage");
    scanChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> homeItems = [
      Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            SizedBox(
              width: vP * 5,
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Entypo.dots_two_horizontal,
                color: Color(0xff957be2),
              ),
            ),
            Text(
              "    TRACKAWARE",
              style: TextStyle(color: Color(0xff957be2), fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: vP * 5,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Good " + greeting(),
                  style: TextStyle(color: Color(0xffffffff), fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Text(
                  globals.userName == 'test' ? 'Thomas Collins' : globals.userName!.capitalizeFirstofEach(),
                  style: TextStyle(
                    fontFamily: "Roboto Mono", fontSize: 30, fontWeight: FontWeight.w700, color: Color(0xffffffff),
                    //fontWeight: FontWeight.w300,
                  ),
                ),
                Text('- - Today Orders: ' + globals.todayOrder!.length.toString(), style: TextStyle(color: Color(0xffffffff), fontSize: 14))
              ],
            ),
          ],
        ),
      ),
      Row(
        children: [_isLoading ? Container(width: hP * 100, child: Center(child: CircularProgressIndicator())) : getOderList()],
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: hP * 2),
        child: Container(height: 200, width: double.infinity, child: SingleChildScrollView(child: table(globals.scannedCode))),
      ),
      Stack(children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: CupertinoColors.white),
          child: SearchField(
            hint: 'Enter barcode here',
            marginColor: CupertinoColors.white,
            suggestions: globals.listTable,
          ),
        ),
        Positioned(
          top: 12,
          left: hP * 70,
          child: GestureDetector(
            onTap: () {
              setState(() {});

              /*ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                content: Text("Scanning ... "),
              ));*/

              /*setState(() {
                _sendDataWedgeCommand("com.symbol.datawedge.api.SOFT_SCAN_TRIGGER", "START_SCANNING");
              });*/
            },
            child: Container(
              width: 77,
              height: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Color(0xff7d3de7),
              ),
              child: Center(
                child: Text(
                  'Scan',
                  style: TextStyle(
                    color: Color(0xffeae1ff),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: vP * 30,
              width: hP * 95,
              decoration: BoxDecoration(color: Color(0xff2C2C34), borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: ButtonTheme(
                      //height: vP * 2,
                      minWidth: hP * 95,
                      child: RaisedButton(
                        color: Color(0xff44444f),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          //side: BorderSide(color: Color(0xff171721)),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          child: Text(
                            'Tender',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) => Tender()))
                              .then((value) => scanChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError));
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ButtonTheme(
                      //height: vP * 8,
                      minWidth: hP * 95,
                      child: RaisedButton(
                        color: Color(0xff383841),
                        elevation: 0,
                        /*shape: RoundedRectangleBorder(
                                              //side: BorderSide(color: Color(0xff171721)),
                                              borderRadius: BorderRadius.circular(15),
                                            ),*/
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 0,
                          ),
                          child: Text(
                            'Pickup',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ButtonTheme(
                      //height: vP * 8,
                      minWidth: hP * 95,
                      child: RaisedButton(
                        color: Color(0xff2C2C34),
                        elevation: 0,
                        /*shape: RoundedRectangleBorder(
                                              //side: BorderSide(color: Color(0xff171721)),
                                              borderRadius: BorderRadius.circular(15),
                                            ),*/
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          child: Text(
                            'Deliver',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: Color(0xff1f1d1d),
      body: SingleChildScrollView(
        child: Column(
          children: homeItems,
        ),
      ),
    );
  }

  getTodayTender() async {
    setState(() {
      _isLoading = true;
    });
    String today = DateFormat("MM/dd/yyyy").format(DateTime.now());

    print('Getting today orders');
    var headers = {'Authorization': 'Basic cmtoYW5kaGVsZGFwaTppMjExVTI7', 'Content-Type': 'application/x-www-form-urlencoded', 'Cookie': 'JSESSIONID=8137707E83FC07BAF1EDF4EBFCE3A4EC'};
    var request = http.Request('POST', Uri.parse('https://na3.sensitel.com/trackaware/handheldapi/trackinfo/'));
    request.bodyFields = {'user': 'all', 'sdate': today, 'edate': today, 'stime': '00:00:00', 'etime': '23:59:00', 'status': 'tender'};
    request.headers.addAll(headers);

    var response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      Iterable jsonResult = json.decode(result)['results'];

      List<Results> listResult = List<Results>.from(jsonResult.map((model) => Results.fromJson(model)));

      globals.todayOrder = listResult;
    } else {
      print(response.reasonPhrase);
    }
    setState(() {
      _isLoading = false;
    });
    globals.customCardTapped = List.filled(globals.todayOrder!.length, false);
  }

  bool move = false;
  getOderList() {
    return Expanded(
        child: AnimatedContainer(
      height: globals.customCardTapped.contains(true) ? 350 : 250,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeIn,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, position) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Listener(
                onPointerUp: (_) {
                  setState(() {});
                },
                child: SlimyCard(
                  index: position,
                  color: Color(0xff8d8c8c),
                  width: 300,
                  topCardHeight: 150,
                  bottomCardHeight: 100,
                  borderRadius: 15,
                  slimeEnabled: true,
                  topCardWidget: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(globals.todayOrder![position].tag),
                    ],
                  ),
                  bottomCardWidget: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: Text(
                          'Cancel',
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                        style: ElevatedButton.styleFrom(primary: Color(0xffec5b5b), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text(
                          'Accept',
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                        style: ElevatedButton.styleFrom(primary: Color(0xff2CC869), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
          itemCount: globals.todayOrder!.length),
    ));
  }
}
