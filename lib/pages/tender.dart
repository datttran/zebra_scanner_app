import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:zebra_trackaware/classes/pickupPart.dart';
import 'package:zebra_trackaware/globals.dart' as globals;

import '../constants.dart';
///////////////////////////

Widget? bullet;
final _controllerO = TextEditingController();
final _controllerD = TextEditingController();
TextEditingController quantity = TextEditingController(text: '1');
TextEditingController orderN = TextEditingController();
TextEditingController partN = TextEditingController(text: '');
TextEditingController toolN = TextEditingController();
String priority = 'P1';
bool fieldTapped = false;
int? tappedField;
Icon iconO = Icon(
  FontAwesome.unlock,
  color: Colors.greenAccent,
  size: 15,
);
Icon iconP = Icon(
  FontAwesome.unlock,
  color: Colors.greenAccent,
  size: 15,
);
Icon iconT = Icon(
  FontAwesome.lock,
  color: Colors.redAccent,
  size: 15,
);
bool orderLocked = false;
bool partLocked = false;
bool toolLocked = false;
var activeColor = [Color(0xff4689ee), Color(0xff4843de)];
var inactiveColor = [Color(0xff85afef).withOpacity(.4), Color(0xff7470db).withOpacity(.4)];

//////////////////

class Tender extends StatefulWidget {
  @override
  TenderTab createState() => TenderTab();
}

int pickUpPartCount = -1;
int pickUpExternalCount = -1;

class TenderTab extends State<Tender> with WidgetsBindingObserver {
  String _scanBarcode = 'N/A';
  String location = 'Home';
  String destination = 'Destination';
  Color kitColor = Colors.blueAccent;
  // Platform messages are asynchronous, so we initialize in an async method.
  //TESTING AREA

  static const EventChannel scanChannelTender = EventChannel('com.zebra_trackaware/scan');
  static const MethodChannel methodChannel = MethodChannel('com.zebra_trackaware/command');

  Future<void> _sendDataWedgeCommand(String command, String parameter) async {
    try {
      String argumentAsJson = jsonEncode({"command": command, "parameter": parameter});

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

  createTenderTicket(barcode) {
    print('creating ticket');
    print(orderN);
    print(partN);
    print(toolN);
    if (true) {
      PickUpPart pickupItem = new PickUpPart();
      pickupItem.orderNumber = orderN.toString();
      pickupItem.partNumber = partN.toString();
      pickupItem.priority = priority;
      pickupItem.toolNumber = toolN.toString();
      pickupItem.location = _controllerO.text;
      pickupItem.destination = _controllerD.text;
      pickupItem.isSynced = 0;
      pickupItem.quantity = quantity.text;
      pickupItem.tagType = type.toString();

      print('tool N is ' + toolN.toString());
      globals.tenderList.insert(0, pickupItem);

      var contain = globals.tenderList.where((element) => element.orderNumber == orderN);

      /*if (contain.isEmpty) {
      print('not contain');
      globals.tenderList.insert(0, pickupItem);
    } else {
      print('contain');
      int t = globals.tenderList.indexOf(contain.first);
      print('t = ' + t.toString());
      globals.tenderList[t] = pickupItem;
    }*/
    } else {
      print('not support');
      print(globals.lengthLimit);
      print(orderN.toString().length.toString());
      print(orderN);
    }
  }

  String? scannedCode;
  List<String> scannedList = [];
  void _onEvent(event) {
    setState(() {
      Map barcodeScan = jsonDecode(event);
      scannedCode = barcodeScan['scanData'];
      List<String> tempList = scannedCode!.split('\n');
      tempList = tempList + scannedList;
      scannedList = tempList.toSet().toList();
      scannedList.sort();
      print(scannedList);
    });

    SystemChrome.restoreSystemUIOverlays();
  }

  void _onError(Object error) {
    setState(() {
      scannedCode = "Barcode: error";
    });
  }

  /////////////////////////////////////END TESTING HERE

  List<Color> active1 = [Color(0xff4689ee), Color(0xff4843de)];

  var activeCase = [
    [activeColor, inactiveColor, inactiveColor],
    [inactiveColor, activeColor, inactiveColor],
    [inactiveColor, inactiveColor, activeColor],
  ];

  List active = [activeColor, inactiveColor, inactiveColor];

  @override
  initState() {
    createBullet();
    _createProfile("TenderPage");
    scanChannelTender.receiveBroadcastStream().listen(_onEvent, onError: _onError);

    //globals.honeywellScanner.stopScanner();

    //_controllerO.text = globals.currentSite;
    super.initState();
  }

  @override
  void dispose() {
    pickUpPartCount = -1;
    pickUpExternalCount = -1;

    //pickupScanner.stopScanner();
    super.dispose();
  }

  List ticketHolder = globals.useToolNumber ? [orderN.text, partN.text, toolN.text] : [orderN.text, partN.text];
  createBullet() {
    bullet = Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: ticketHolder.length == 3
            ? [
                Icon(
                  Entypo.dot_single,
                  color: ticketHolder[0] == "" ? Colors.white.withOpacity(.5) : Colors.greenAccent,
                ),
                Icon(
                  Entypo.dot_single,
                  color: ticketHolder[1] == "" ? Colors.white.withOpacity(.5) : Colors.greenAccent,
                ),
                Icon(
                  Entypo.dot_single,
                  color: ticketHolder[2] == "" ? Colors.white.withOpacity(.5) : Colors.greenAccent,
                ),
              ]
            : [
                Icon(
                  Entypo.dot_single,
                  color: ticketHolder[0] == "" ? Colors.white.withOpacity(.5) : Colors.greenAccent,
                ),
                Icon(
                  Entypo.dot_single,
                  color: ticketHolder[1] == "" ? Colors.white.withOpacity(.5) : Colors.greenAccent,
                ),
              ],
      ),
    );
    return bullet;
  }

  autoField(barcode) {
    bool result = false;
    if (barcode.length >= 10 && barcode.length <= globals.orderLimit) {
      ticketHolder[0] = barcode;
      orderN.text = barcode;
      result = true;
    } else if (barcode.length == globals.containerLimit) {
      ticketHolder[1] = barcode;
      partN.text = barcode;
      result = true;
    } else if (barcode.length >= globals.trackingLimit) {
      ticketHolder[2] = barcode;
      toolN.text = barcode;
      result = true;
    } else {
      result = false;
    }
    print(result);
    setState(() {
      createBullet();
    });
    return result;
  }

  checkLocationField() {
    if (_controllerO.text == '') {
      showToast('Please Select: Origin Location', context: context, axis: Axis.horizontal, alignment: Alignment.center, position: StyledToastPosition.center);
      setState(() {
        isOpen = true;
        height = vP * 80;
      });
      return false;
    } else if (_controllerD.text == '') {
      setState(() {
        isOpen = true;
        height = vP * 80;
      });
      showToast('Please Select: Destination', context: context, axis: Axis.horizontal, alignment: Alignment.center, position: StyledToastPosition.center);
      return false;
    } else {
      return true;
    }
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  var type = [];

  bool showPerformance = false;
  onSettingCallback() {
    setState(() {
      showPerformance = !showPerformance;
    });
  }

  Widget getTenderList() {
    return Expanded(
        child: Padding(
            padding: EdgeInsets.fromLTRB(0, 0.0, 0, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      tenderCard(),
                      SizedBox(height: 20),
                      scannedList.length > 0 ? pickupCard() : Container(),
                    ],
                  )),
            )));
  }

  /*Widget tenderCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        height: vP * 25,
        width: hP * 93,
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
              colors: [Color(0xffffffff).withOpacity(0.1), Color(0xcbd2e2ff).withOpacity(0.1)], begin: Alignment.topLeft, end: Alignment.bottomRight, stops: [0.0, 1.0], tileMode: TileMode.clamp),
          borderRadius: BorderRadius.circular(30),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              width: hP * 70,
              child: Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                active = active.reversed.toList();
                              });
                            },
                            child: Container(
                              //margin: EdgeInsets.only(left: 20, bottom: 10, right: 20),
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: active[0],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              ),
                              child: Text(
                                'P1',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                active = active.reversed.toList();
                              });
                            },
                            child: Container(
                              //margin: EdgeInsets.only(left: 20, bottom: 1, right: 20),
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: active[1],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              ),
                              child: Text(
                                'P2',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: hP * 15,
                          ),
                          Text(
                            'Origin',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: vP * 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            width: hP * 70,
                            child: TextField(
                              controller: _controllerO,
                              readOnly: true,
                              onTap: () {
                                setState(() {
                                  _controllerO.text = globals.lList[0];
                                });
                                showPickerO();
                              },
                              style: TextStyle(color: Color(0xffc5c5cb)),
                              //keyboardType: TextInputType.number,
                              onChanged: (value) {
                                //Do something with the user input.
                              },
                              decoration: InputDecoration(
                                hintText: 'Location',
                                hintStyle: TextStyle(color: Colors.white70.withOpacity(.2)),
                                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xff8091ff), width: .5),
                                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xff4d5cde), width: 1.0),
                                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: vP * 1,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: hP * 15,
                          ),
                          Text(
                            'Destination',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: vP * 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            width: hP * 70,
                            child: TextField(
                              controller: _controllerD,
                              readOnly: true,
                              onTap: () {
                                setState(() {
                                  _controllerD.text = globals.lList[0];
                                });
                                showPickerD();
                              },
                              style: TextStyle(color: Color(0xffc5c5cb)),
                              //keyboardType: TextInputType.number,
                              onChanged: (value) {
                                //Do something with the user input.
                              },
                              decoration: InputDecoration(
                                hintText: 'Location',
                                hintStyle: TextStyle(color: Colors.white70.withOpacity(.2)),
                                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xff8091ff), width: .5),
                                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xff4d5cde), width: 1.0),
                                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      //loginBoxes[shareValue],
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }*/
  double _quantity = 1;
  bool isOpen = false;
  double height = vP * 20;
  Widget tenderCard() {
    return Padding(
      padding: EdgeInsets.only(top: 0.0),
      child: AnimatedContainer(
        height: height,
        width: hP * 93,
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
              colors: [Color(0xffffffff).withOpacity(0.1), Color(0xcbd2e2ff).withOpacity(0.1)], begin: Alignment.topLeft, end: Alignment.bottomRight, stops: [0.0, 1.0], tileMode: TileMode.clamp),
          borderRadius: BorderRadius.circular(30),
        ),
        duration: Duration(milliseconds: 500),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              width: hP * 70,
              child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ListView(
                    children: <Widget>[
                      Visibility(
                        visible: !isOpen,
                        child: Slider(
                          value: double.parse(quantity.text),
                          min: 1,
                          max: globals.max,
                          divisions: globals.max.toInt(),
                          label: _quantity.toStringAsFixed(0),
                          onChanged: (value) {
                            setState(() {
                              _quantity = value;
                              quantity.text = value.toStringAsFixed(0);
                            });
                          },
                        ),
                      ),
                      Theme(
                        data: Theme.of(context).copyWith(cardColor: Colors.transparent),
                        child: ExpansionPanelList(
                          animationDuration: Duration(milliseconds: 500),
                          elevation: 0,
                          expansionCallback: (int index, bool isExpanded) {
                            setState(() {
                              fieldTapped = false;
                              isOpen = !isOpen;
                              height = isOpen == true ? vP * 80 : vP * 20;
                            });

                            print(isOpen);
                          },
                          children: [
                            ExpansionPanel(
                                body: Column(
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: hP * 15,
                                        ),
                                        Text(
                                          'Origin',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Container(
                                          width: hP * 70,
                                          child: TextField(
                                            controller: _controllerO,
                                            readOnly: true,
                                            onTap: () {
                                              setState(() {
                                                _controllerO.text = globals.lList[0];
                                              });
                                              showPickerO();
                                            },
                                            style: TextStyle(color: Color(0xffc5c5cb)),
                                            //keyboardType: TextInputType.number,
                                            onChanged: (value) {
                                              //Do something with the user input.
                                            },
                                            decoration: InputDecoration(
                                              hintText: 'Location',
                                              hintStyle: TextStyle(color: Colors.white70.withOpacity(.2)),
                                              contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Color(0xff8091ff), width: .5),
                                                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Color(0xff4d5cde), width: 1.0),
                                                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ), // ORIGIN
                                    SizedBox(
                                      height: vP * 5,
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: hP * 15,
                                        ),
                                        Text(
                                          'Destination',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: vP * 1,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Container(
                                          width: hP * 70,
                                          child: TextField(
                                            controller: _controllerD,
                                            readOnly: true,
                                            onTap: () {
                                              setState(() {
                                                _controllerD.text = globals.lList[0];
                                              });
                                              showPickerD();
                                            },
                                            style: TextStyle(color: Color(0xffc5c5cb)),
                                            //keyboardType: TextInputType.number,
                                            onChanged: (value) {
                                              //Do something with the user input.
                                            },
                                            decoration: InputDecoration(
                                              hintText: 'Location',
                                              hintStyle: TextStyle(color: Colors.white70.withOpacity(.2)),
                                              contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Color(0xff8091ff), width: .5),
                                                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Color(0xff4d5cde), width: 1.0),
                                                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ), // DESTINATION
                                    SizedBox(
                                      height: vP * 5,
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: hP * 15,
                                        ),
                                        Text(
                                          'Quantity',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: vP * 1,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Container(
                                          width: hP * 70,
                                          child: TextField(
                                            controller: quantity,
                                            readOnly: false,
                                            onTap: () {},
                                            style: TextStyle(color: Color(0xffc5c5cb)),
                                            keyboardType: TextInputType.number,
                                            onChanged: (value) {
                                              if (double.parse(value) > globals.max) {
                                                setState(() {
                                                  _quantity = globals.max;
                                                });
                                              } else {
                                                setState(() {
                                                  _quantity = double.parse(value);
                                                });
                                              }

                                              //Do something with the user input.
                                            },
                                            decoration: InputDecoration(
                                              hintText: 'Quantity',
                                              hintStyle: TextStyle(color: Colors.white70.withOpacity(.2)),
                                              contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Color(0xff8091ff), width: .5),
                                                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Color(0xff4d5cde), width: 1.0),
                                                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ), // QUANTITY

                                    // ORDER NUMBER
                                  ],
                                ),
                                isExpanded: isOpen,
                                headerBuilder: (BuildContext context, bool isExpanded) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isOpen = !isOpen;
                                        height = isOpen == true ? vP * 70 : vP * 20;
                                      });
                                    },
                                    child: Container(
                                      color: Colors.transparent,
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: hP * 15,
                                          ),
                                          Text(
                                            'Order Details',
                                            style: TextStyle(color: Colors.white70),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                })
                          ],
                        ),
                      )

                      //loginBoxes[shareValue],
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }

  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return StyledToast(
      locale: const Locale('en', 'US'),
      //You have to set this parameters to your locale
      textStyle: TextStyle(fontSize: 16.0, color: Colors.white),
      backgroundColor: Color(0x99000000),
      borderRadius: BorderRadius.circular(5.0),
      textPadding: EdgeInsets.symmetric(horizontal: 17.0, vertical: 10.0),
      toastAnimation: StyledToastAnimation.size,
      reverseAnimation: StyledToastAnimation.size,
      startOffset: Offset(0.0, -1.0),
      reverseEndOffset: Offset(0.0, -1.0),
      duration: Duration(seconds: 4),
      animDuration: Duration(seconds: 1),
      alignment: Alignment.center,
      toastPositions: StyledToastPosition.center,
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.fastOutSlowIn,
      dismissOtherOnShow: true,
      fullWidth: false,
      isHideKeyboard: false,
      isIgnoring: true,
      child: Material(
        color: Color(0xff2C2C34),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: SingleChildScrollView(
              child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      height: vP * 88,
                      margin: EdgeInsets.symmetric(horizontal: hP * 3.5, vertical: vP * 1),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xff2C2C34),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onLongPress: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      height: vP * 3,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Color(0xff171721),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.only(top: vP * 0.3),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Text(
                                              '   Total Order: ' + globals.tenderList.length.toString(),
                                              style: TextStyle(color: Colors.white70, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  /*globals.tenderList.length > 2
                                    ? Container(
                                        margin: EdgeInsets.symmetric(vertical: vP * 2),
                                        height: vP * 5,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Color(0xfff30a37),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(top: vP * 0.3),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(bottom: 1.5),
                                                child: Icon(
                                                  FontAwesome.remove,
                                                  color: Colors.white70,
                                                  size: 15,
                                                ),
                                              ),
                                              Text(
                                                ' Remove all    ',
                                                style: TextStyle(color: Colors.white70, fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : SizedBox(),*/
                                  //tenderCard(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      bullet!,
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                active = activeCase[0];
                                                priority = 'P1';
                                              });
                                            },
                                            child: Container(
                                              margin: EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 10),
                                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: active[0],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                              ),
                                              child: Text(
                                                'P1',
                                                style: TextStyle(color: Colors.white70),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                active = activeCase[1];
                                                priority = 'P2';
                                              });
                                            },
                                            child: Container(
                                              margin: EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 10),
                                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: active[1],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                              ),
                                              child: Text(
                                                'P2',
                                                style: TextStyle(color: Colors.white70),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  getTenderList(),
                                ],
                              )),
                        ),
                      )),
                  Visibility(
                    visible: globals.popup == 0,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: hP * 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: ButtonTheme(
                              height: vP * 8,
                              minWidth: hP * 5,
                              child: RaisedButton(
                                color: Color(0xff7a7aff),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  //side: BorderSide(color: Color(0xff171721)),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                                  child: Text(
                                    'SEND',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                onPressed: () async {},
                              ),
                            ),
                          ),
                          Visibility(
                            visible: isOpen,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: hP * 3),
                              child: ButtonTheme(
                                height: vP * 8,
                                minWidth: hP * 20,
                                child: RaisedButton(
                                  color: Color(0xff63a2ff),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: hP * 12, vertical: 4),
                                    child: Text(
                                      'Confirm',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  onPressed: () async {
                                    fieldTapped = false;
                                    tappedField = null;
                                    print(ticketHolder);

                                    if (!ticketHolder.contains('')) {
                                      print('TODO://Creating ticket');
                                      //createTenderTicket(orderN.text, partN.text, toolN.text, true);
                                      print(ticketHolder);
                                      showToast('Order Created', context: context, axis: Axis.horizontal, alignment: Alignment.bottomCenter, position: StyledToastPosition.center);

                                      setState(() {
                                        isOpen = false;
                                        height = vP * 20;
                                      });

                                      //Finished
                                      ticketHolder = globals.useToolNumber
                                          ? [
                                              orderLocked ? orderN.text = orderN.text : orderN.text = '',
                                              partLocked ? partN.text = partN.text : partN.text = '',
                                              toolLocked ? toolN.text = toolN.text : toolN.text = ''
                                            ]
                                          : [orderLocked ? orderN.text = orderN.text : orderN.text = '', partLocked ? partN.text = partN.text : partN.text = ''];
                                      print(globals.tenderList);
                                    }

                                    setState(() {
                                      isOpen = false;
                                      height = vP * 20;
                                      //quantity.text = '1';
                                      createBullet();
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          /*Expanded(
                          child: ButtonTheme(
                            height: vP * 8,
                            minWidth: hP * 10,
                            child: RaisedButton(
                              color: Color(0xff2C2C34),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                //side: BorderSide(color: Color(0xff171721)),
                                borderRadius: BorderRadius.horizontal(right: Radius.circular(15)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                                child: Text(
                                  'Scan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                scanBarcodeNormal();
                              },
                            ),
                          ),
                        ),*/
                        ],
                      ),
                    ),
                  )
                ],
              ),
              _isLoading
                  ? Container(
                      color: Colors.transparent,
                      height: vP * 85,
                      child: Center(
                        child: Column(
                          children: [
                            SizedBox(
                              height: vP * 25,
                            ),
                            CircularProgressIndicator(),
                          ],
                        ),
                      ),
                    )
                  : Container(),
            ],
          )),
        ),
      ),
    );
  }

  pickupCard() {
    return Slidable(
      actionPane: SlidableScrollActionPane(),
      actions: [
        IconSlideAction(
          caption: 'Remove',
          color: Colors.transparent,
          icon: Icons.delete_forever,
          onTap: () {
            setState(() {
              scannedList = [];
            });
          },
        ),
      ],
      child: GestureDetector(
        onTap: () async {
          showToast('Order no.  } ', context: context, axis: Axis.horizontal, alignment: Alignment.center, position: StyledToastPosition.center);
        },
        child: Card(
          elevation: 0,
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: EdgeInsets.fromLTRB(0, 0, 0, vP * 2),
          child: Container(
              height: 110,
              decoration: new BoxDecoration(
                gradient: new LinearGradient(
                    colors: [Color(0xffbab8ff).withOpacity(.5), Color(0xff352eff).withOpacity(.5)], begin: Alignment.topLeft, end: Alignment.bottomRight, stops: [0.0, 1.0], tileMode: TileMode.clamp),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: hP * 1,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              padding: EdgeInsets.fromLTRB(0, 12.0, 0.0, 0.0),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Container(
                                    height: 17,
                                    padding: EdgeInsets.fromLTRB(5.0, 2, 5.0, 0),
                                    margin: EdgeInsets.only(right: 5),
                                    decoration: new BoxDecoration(
                                        color: Color(0xe2d1fffd).withOpacity(.2),
                                        borderRadius: new BorderRadius.only(
                                            topLeft: const Radius.circular(16.0),
                                            topRight: const Radius.circular(16.0),
                                            bottomLeft: const Radius.circular(16.0),
                                            bottomRight: const Radius.circular(16.0))),
                                    child: Text(
                                      " " + (2323).toString() + " ",
                                      style: TextStyle(color: Color(0xe2131313).withOpacity(.2), fontSize: 11.0, fontWeight: FontWeight.bold),
                                    )),
                              )),
                          SizedBox(
                            height: vP * .5,
                          ),
                          Container(
                              padding: EdgeInsets.fromLTRB(20, 0, 24.0, 0.0),
                              child: Align(alignment: Alignment.topRight, child: Text("Order", textAlign: TextAlign.right, style: const TextStyle(color: const Color(0xffffffff), fontSize: 11.0)))),
                        ],
                      ),
                      SizedBox(
                        width: hP * 1,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(

                              //color: Colors.red,
                              width: hP * 35,
                              padding: EdgeInsets.fromLTRB(0.0, 12, 0.0, 0),
                              child: Text('${{scannedList}.toString().hashCode}',
                                  maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.left, style: const TextStyle(color: const Color(0xffffffff), fontSize: 16.0))),
                          SizedBox(
                            height: vP * .5,
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                                //color: Colors.white,
                                width: hP * 35,
                                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: Text('2131231200-C',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(color: const Color(0xffe0dee7), fontStyle: FontStyle.normal, fontSize: 11.0))),
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 18,
                          ),
                          Container(
                            width: hP * 15.57,
                            decoration: new BoxDecoration(
                                color: Color(0xe2d1fffd).withOpacity(.2),
                                borderRadius: new BorderRadius.only(
                                    topLeft: const Radius.circular(16.0), topRight: const Radius.circular(5.0), bottomLeft: const Radius.circular(16.0), bottomRight: const Radius.circular(0.0))),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2),
                              child: Center(
                                child: Text(
                                  '${scannedList.length}',
                                  style: TextStyle(color: Color(0xffeae9ff), fontSize: 11.0),
                                ),
                              ),
                            ),
                          ),
                          Container(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 0.0),
                              child: Align(alignment: Alignment.topRight, child: Text('Quantity', textAlign: TextAlign.right, style: const TextStyle(color: const Color(0xffffffff), fontSize: 11.0)))),
                        ],
                      )
                      /*Icon(
                                        Entypo.dot_single,
                                        color: Color(0xfff1f8ff).withOpacity(.5),
                                        size: 32,
                                      )*/
                    ],
                  ),
                  Divider(
                    color: const Color(0xfffff2f2),
                  ),
                  Container(
                      padding: EdgeInsets.fromLTRB(18.0, 5.0, 18.0, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Text("Location", style: const TextStyle(color: const Color(0xff241835), fontWeight: FontWeight.w400, fontStyle: FontStyle.normal, fontSize: 13.0)),
                              Text("", style: TextStyle(color: Color(0xff0e0935).withOpacity(.5), fontWeight: FontWeight.w400, fontSize: 11.0))
                            ],
                          ),
                          Icon(
                            Icons.sync_alt,
                            size: vP * 2,
                            color: Colors.white70.withOpacity(.3),
                          ),
                          Column(
                            children: <Widget>[
                              Text("Destination", style: const TextStyle(color: const Color(0xff241835), fontWeight: FontWeight.w400, fontStyle: FontStyle.normal, fontSize: 13.0)),
                              Text('', style: TextStyle(color: Color(0xff0e0935).withOpacity(.5), fontWeight: FontWeight.w400, fontSize: 11.0))
                            ],
                          ),
                        ],
                      ))
                ],
              )),
        ),
      ),
    );
  }

/*  _sendToServer(TransactionRequest transactionRequest) async {
    try {
      final response = await http.post(
        Uri.parse(globals.baseUrl + '/transaction/'),
        headers: <String, String>{'Content-Type': 'application/json', 'Authorization': 'Basic cmtoYW5kaGVsZGFwaTppMjExVTI7'},
        body: jsonEncode(transactionRequest.toJson()),
      );
      print(response.statusCode);
      globals.responseCode = response.statusCode;

      print(transactionRequest.toString());
      print('finish');
      return true;
    } catch (E) {
      print('fail to send to server');
      return false;
    }
  }*/

  /*_generateTransactionList(pickUpPart) async {
    print('generate transaction');
    print(pickUpPart.toString());

    TransactionRequest transactionRequest = TransactionRequest();

    transactionRequest.handHeldId = 'Android_TestDevice';
    transactionRequest.id = 232;

    transactionRequest.location = _controllerO.text;

    transactionRequest.status = 'tender';
    transactionRequest.user = globals.user != null ? globals.user : 'testtest';

    transactionRequest.packages = [tenderPacketFromPickUpPart(pickUpPart)];
    print(transactionRequest.toString());

    //_transactionRequestItems.add(transactionRequest);
    var sendResult = await _sendToServer(transactionRequest);
    print('result is' + sendResult.toString());
    return sendResult;
  }
*/
  int? selectedValue;
  showPickerO() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return CupertinoPicker(
            backgroundColor: Colors.white,
            onSelectedItemChanged: (value) {
              setState(() {
                _controllerO.text = globals.lList[value];
              });
            },
            itemExtent: 32.0,
            children: globals.locationList,
          );
        });
  }

  showPickerD() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return CupertinoPicker(
            backgroundColor: Colors.white,
            onSelectedItemChanged: (value) {
              setState(() {
                _controllerD.text = globals.lList[value];
              });
            },
            itemExtent: 32.0,
            children: globals.locationList,
          );
        });
  }

  _getDeviceInfo() {
    //get device info here
  }
}
