import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:zebra_trackaware/classes/order.dart';
import 'package:zebra_trackaware/constants.dart';
import 'package:zebra_trackaware/globals.dart' as globals;
import 'package:zebra_trackaware/logics/pageRoute.dart';
import 'package:zebra_trackaware/logics/string_extension.dart';
import 'package:zebra_trackaware/pages/tender.dart';
import 'package:zebra_trackaware/pages/test.dart';
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
  static const EventChannel scanChannel = EventChannel('com.zebra_trackaware/scan');
  static const MethodChannel methodChannel = MethodChannel('com.zebra_trackaware/command');
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
    print('hello');
    print(event);
    setState(() {
      Map barcodeScan = jsonDecode(event);
      scannedCode = barcodeScan['scanData'];
    });
    print(globals.scannedCode);
  }

  void _onError(Object error) {
    setState(() {
      scannedCode = "Barcode: error";
    });
  }

  @override
  void initState() {
    getTodayTender();
    _createProfile("newZebra");
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
              width: verticalPixel * 5,
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
        padding: EdgeInsets.symmetric(vertical: 18.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: verticalPixel * 5,
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
        children: [_isLoading ? Container(height: 300, width: horizontalPixel * 100, child: Center(child: CircularProgressIndicator())) : getOderList()],
      ),
      Container(
        height: verticalPixel * 20,
        width: horizontalPixel * 90,
        color: Colors.transparent,
        child: GridView.count(
          crossAxisCount: 3,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(toPage(Tender()));
              },
              child: Container(
                width: 87,
                height: 87,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 87,
                      height: 87,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Color(0xffe2e2e2),
                      ),
                      padding: EdgeInsets.only(
                        left: verticalPixel * 2,
                        right: 22,
                        top: 5,
                        bottom: 62,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/list-svgrepo-com.svg',
                          height: verticalPixel * 105,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 87,
              height: 87,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Test()));
                    },
                    child: Container(
                      width: 87,
                      height: 87,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Color(0xffe2e2e2),
                      ),
                      padding: EdgeInsets.only(
                        left: verticalPixel * 2,
                        right: 22,
                        top: 5,
                        bottom: 62,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 44,
                            height: 20,
                            child: Text(
                              "Pickup",
                              style: TextStyle(
                                color: Color(0xff1c1c1c),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                print('tapped');
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  content: Text("Switching Mode ... "),
                ));

                setState(() {
                  _sendDataWedgeCommand("com.symbol.datawedge.api.SOFT_SCAN_TRIGGER", "START_SCANNING");
                });
              },
              child: Container(
                width: 87,
                height: 87,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 87,
                      height: 87,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Color(0xffe2e2e2),
                      ),
                      padding: EdgeInsets.only(
                        left: verticalPixel * 2,
                        top: 5,
                        bottom: 62,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 51,
                            height: 20,
                            child: Text(
                              globals.scannedCode,
                              style: TextStyle(
                                color: Color(0xff1c1c1c),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      Container(
        width: 97,
        height: 32,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 97,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xffc4c4c4),
              ),
              padding: const EdgeInsets.only(
                left: 28,
                right: 29,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 40,
                    height: 18,
                    child: Text(
                      "START",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
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
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Listener(
                onPointerUp: (_) {
                  setState(() {});
                },
                child: SlimyCard(
                  index: position,
                  color: Color(0xff4d76b5),
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
                  bottomCardWidget: Text('hi'),
                ),
              ),
            );
          },
          itemCount: globals.todayOrder!.length),
    ));
  }
}
