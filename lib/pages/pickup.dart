import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:http/http.dart' as http;
import 'package:zebra_trackaware/classes/pickupPart.dart';
import 'package:zebra_trackaware/globals.dart' as globals;
import 'package:zebra_trackaware/logics/location_response.dart';

checkLocationBeforeScan() {
  ////print('current long  ' + _locationData.longitude.toString());
  ////print('current lat ' + _locationData.latitude.toString());
  if (globals.currentSite == 'Unknown') {
    List<double> dList = [];

    /// List contains distances from current position to location in locationMap
    globals.locationMap.forEach((element) {
      double d = ddToDistance(element.lat, element.long, globals.currentLat, globals.currentLong) * 1000;
      dList.add(d);
      ////print('distance is ' + d.toString() + 'm');

      /*if (longRange.abs() < .00015 && latRange.abs() < .00015) {
        result = element.id;
      }*/
    });
    double x = dList.reduce(min);
    if (x <= 100) {
      int i = dList.indexOf(x);
      globals.currentSite = globals.locationMap[i].id;
    } else {
      globals.currentSite = 'Unknown';
    }
  }
}

String autoOrigin(lat, long) {
  String result;

  if (globals.locationMap.length > 0) {
    ////print('[autoOrigin] current long  ' + globals.currentLong.toString());
    ////print('[autoOrigin] current lat ' + globals.currentLat.toString());
    List<double> dList = [];

    /// List contains distances from current position to location in locationMap
    globals.locationMap.forEach((element) {
      double d = ddToDistance(element.lat, element.long, lat, long) * 1000;
      dList.add(d);
      ////print('distance is ' + d.toString() + 'm');

      /*if (longRange.abs() < .00015 && latRange.abs() < .00015) {
        result = element.id;
      }*/
    });
    double x = dList.reduce(min);
    if (x <= globals.sensitivity) {
      int i = dList.indexOf(x);
      result = globals.locationMap[i].id;
    } else {
      result = 'Unknown';
    }
    ////print(dList);
    ////print(result);

    return result;
  } else {
    ////print('locationData is empty');

    return 'Unknown';
  }
}

createTicket(barcode) {
  if (globals.lengthLimit == barcode.toString().length.toString()) {
    PickUpPart pickupItem = new PickUpPart();
    pickupItem.orderNumber = barcode.toString();
    pickupItem.location = globals.currentSite;
    pickupItem.destination = 'Unknown';
    pickupItem.isSynced = 0;

    var contain = globals.pickupList.where((element) => element.orderNumber == barcode);
    if (contain.isEmpty) {
      globals.pickupList.insert(0, pickupItem);
      DBProvider.db.insertPickUpPart(pickupItem);
    }
  }
}

// for na2

void getOrigin() async {
  globals.futureLocation = await fetchLocation();
  globals.originLocations = json.decode(globals.futureLocation).map((data) => LocationResponse.fromJson(data)).toList();
  if (globals.originLocations != null) {
    globals.locationList = [];
    globals.lList = [];
    globals.originLocations.forEach((element) {
      Widget block = Text(element.code);
      globals.locationList.add(block);
      globals.lList.add(element.code);

      globals.locationMap.add(Loc(id: element.code));
    });
  }

  globals.locationList = globals.locationList.toSet().toList();
  globals.lList = globals.lList.toSet().toList();

  globals.locationMap = globals.locationMap.toSet().toList();

  //globals.currentSite = autoOrigin(_locationData);
} // generate locations list from API

final R = 6372.8; // In kilometers

double ddToDistance(double lat1, lon1, lat2, lon2) {
  double dLat = _toRadians(lat2 - lat1);
  double dLon = _toRadians(lon2 - lon1);
  lat1 = _toRadians(lat1);
  lat2 = _toRadians(lat2);
  double a = pow(sin(dLat / 2), 2) + pow(sin(dLon / 2), 2) * cos(lat1) * cos(lat2);
  double c = 2 * asin(sqrt(a));
  return R * c;
}

double _toRadians(double degree) {
  return degree * pi / 180;
}

class PickUpTabWidget extends StatefulWidget {
  final TabController tabController;
  final String currentSite;

  PickUpTabWidget({this.tabController, this.currentSite});
  @override
  PickUpTab createState() => PickUpTab();
}

PickUpTabBloc _pickUpTabBloc;
int pickUpPartCount = -1;
int pickUpExternalCount = -1;

class PickUpTab extends State<PickUpTabWidget> with WidgetsBindingObserver implements ScannerCallBack {
  String _scanBarcode = 'N/A';
  String location = 'Home';
  String destination = 'Destination';
  final FocusNode _focusNode = FocusNode();
  // Platform messages are asynchronous, so we initialize in an async method.

  HoneywellScanner pickupScanner = HoneywellScanner();
  bool scannerEnabled = true;
  bool scan1DFormats = true;
  bool scan2DFormats = true;
  String scannedCode;
  List trackerHolder = ["", ""];
  bool kitScanning = false;
  bool _isLoading = false;
  createKit(barcode) {
    if (true) {
      PickUpPart pickupItem = new PickUpPart();
      pickupItem.orderNumber = barcode.toString();
      pickupItem.location = globals.currentSite;
      pickupItem.destination = 'Unknown';
      pickupItem.isSynced = 0;
      pickupItem.tagType = globals.useToolNumber ? '7' : '6';
      pickupItem.partNumber = 'KIT-000000-001';

      var contain = globals.pickupList.where((element) => element.orderNumber == barcode);
      if (contain.isEmpty) {
        globals.pickupList.insert(0, pickupItem);
        DBProvider.db.insertPickUpPart(pickupItem);
        showToast('Kit scanned', context: context, axis: Axis.horizontal, alignment: Alignment.center, position: StyledToastPosition.center);
      } else {
        showToast('Item already scanned', context: context, axis: Axis.horizontal, alignment: Alignment.center, position: StyledToastPosition.center);
      }
    }
  }

  createShipperTicket(barcode) {
    if (barcode.length == globals.lengthLimit) {
      setState(() {
        PickUpPart pickupItem = new PickUpPart();

        pickupItem.orderNumber = barcode[0];
        pickupItem.partNumber = barcode[1];
        pickupItem.location = globals.currentSite;
        pickupItem.destination = "Unknown";
        pickupItem.isSynced = 0;
        pickupItem.tagType = globals.useToolNumber ? '7' : "5";
        var contain = globals.pickupList.where((element) => element.orderNumber == barcode[0]);
        var containD = globals.deliveryList.where((element) => element.orderNumber == barcode[0]);
        if (contain.isEmpty && containD.isEmpty) {
          globals.pickupList.insert(0, pickupItem);
          DBProvider.db.insertPickUpPart(pickupItem);
        } else if (containD.isNotEmpty) {
          showToast('Item already in delivery list', context: context, axis: Axis.horizontal, alignment: Alignment.center, position: StyledToastPosition.center);
        } else {
          showToast('Item already scanned', context: context, axis: Axis.horizontal, alignment: Alignment.center, position: StyledToastPosition.center);
        }
      });
    } else {
      showToast('This barcode is not supported\n Length limit is ${globals.lengthLimit}', context: context, axis: Axis.horizontal, alignment: Alignment.center, position: StyledToastPosition.center);
    }
  }

  createShipperTicketNa1(barcode) {
    if (barcode.length.toString() == globals.lengthLimit) {
      setState(() {
        PickUpPart pickupItem = new PickUpPart();

        pickupItem.orderNumber = barcode;
        pickupItem.location = globals.currentSite;
        pickupItem.destination = "Unknown";
        pickupItem.isSynced = 0;

        var contain = globals.pickupList.where((element) => element.orderNumber == barcode);
        var containD = globals.deliveryList.where((element) => element.orderNumber == barcode);
        if (contain.isEmpty && containD.isEmpty) {
          globals.pickupList.insert(0, pickupItem);
          DBProvider.db.insertPickUpPart(pickupItem);
        } else if (containD.isNotEmpty) {
          showToast('Item already in delivery list', context: context, axis: Axis.horizontal, alignment: Alignment.center, position: StyledToastPosition.center);
        } else {
          showToast('Item already scanned', context: context, axis: Axis.horizontal, alignment: Alignment.center, position: StyledToastPosition.center);
        }
      });
    } else {
      showToast('This barcode is not supported\n Length limit is ${globals.lengthLimit}', context: context, axis: Axis.horizontal, alignment: Alignment.center, position: StyledToastPosition.center);
    }
  }

  @override
  initState() {
    //getOrigin();
    //globals.honeywellScanner.stopScanner();
    pickupScanner.setScannerCallBack(this);
    pickupScanner.startScanner();
    createBullet();
    super.initState();

    //TODO: periodic func here
    Timer.periodic(Duration(seconds: 5), (timer) {
      periodicReload();
    });
  }

  updateScanProperties() {
    List<CodeFormat> codeFormats = [];
    if (scan1DFormats ?? false) codeFormats.addAll(CodeFormatUtils.ALL_1D_FORMATS);
    if (scan2DFormats ?? false) codeFormats.addAll(CodeFormatUtils.ALL_2D_FORMATS);

    pickupScanner.setProperties(CodeFormatUtils.getAsPropertiesComplement(codeFormats));
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  periodicReload() {
    setState(() {});
  }

  Widget bullet;
  createBullet() {
    bullet = Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Entypo.dot_single,
            color: trackerHolder[0] == "" ? Colors.white.withOpacity(.5) : Colors.greenAccent,
          ),
          Icon(
            Entypo.dot_single,
            color: trackerHolder[1] == "" ? Colors.white.withOpacity(.5) : Colors.greenAccent,
          ),
        ],
      ),
    );
    return bullet;
  }

  @override
  onDecoded(String result) async {
    await checkLocationBeforeScan();

    scannedCode = result;
    //print(scannedCode);

    ///////////NEW LOGIC /////////////////////////
    /*if (trackerHolder[0] == '') {
      trackerHolder[0] = scannedCode;
      showToast('Order Number Scanned', context: context, axis: Axis.horizontal, alignment: Alignment.center, position: StyledToastPosition.center);

      setState(() {
        createBullet();
      });
    } else if (trackerHolder[1] == '') {
      trackerHolder[1] = scannedCode;
      showToast('Part Number Scanned', context: context, axis: Axis.horizontal, alignment: Alignment.center, position: StyledToastPosition.center);

      setState(() {
        createBullet();
      });
    }*/

/*    if (kitScanning) {
      createKit(scannedCode);
      setState(() {
        trackerHolder = ['', ''];
        createBullet();
      });
    }*/
    createShipperTicketNa1(scannedCode);

    /*if (!trackerHolder.contains('')) {
      print('create ticket');
      //TODO:// add create ticket function
      createShipperTicket(trackerHolder);

      trackerHolder = ["", ""];
      setState(() {
        createBullet();
      });
    }*/

    /////////////////////////////////////////////

    //////////////DRIVER APP PICKUP LOGIC ////////////////////////

    /*if (globals.lengthLimit == result.toString().length.toString()) {
      setState(() {
        PickUpPart pickupItem = new PickUpPart();

        pickupItem.orderNumber = result;
        pickupItem.location = globals.currentSite;
        pickupItem.destination = "N/A";
        pickupItem.isSynced = 0;
        var contain = globals.pickupList.where((element) => element.orderNumber == result);
        var containD = globals.deliveryList.where((element) => element.orderNumber == result);
        if (contain.isEmpty && containD.isEmpty) {
          globals.pickupList.insert(0, pickupItem);
          DBProvider.db.insertPickUpPart(pickupItem);
        } else if (containD.isNotEmpty) {
          showToast('Item already in delivery list', context: context, axis: Axis.horizontal, alignment: Alignment.center, position: StyledToastPosition.center);
        } else {
          showToast('Item already scanned', context: context, axis: Axis.horizontal, alignment: Alignment.center, position: StyledToastPosition.center);
        }
      });
    } else {
      showToast('This barcode is not supported', context: context, axis: Axis.horizontal, alignment: Alignment.center, position: StyledToastPosition.center);
    }*/
  }

  @override
  onError(Exception error) {
    scannedCode = error.toString();
  }

  bool showPerformance = false;
  onSettingCallback() {
    setState(() {
      showPerformance = !showPerformance;
    });
  }

  Widget getPickUpList() {
    return Expanded(
        child: Padding(
            padding: EdgeInsets.fromLTRB(0, 0.0, 0, 0),
            child: Align(
                alignment: Alignment.topCenter,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  padding: EdgeInsets.fromLTRB(0, verticalPixel * 2, 0, 0),
                  shrinkWrap: false,
                  itemBuilder: (context, position) {
                    if (position == 0 && globals.pickupList.length > 2) {
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              globals.pickupList.forEach((element) async {
                                var count = await DBProvider.db.matchPickupPart(element.orderNumber);
                                setState(() {
                                  if (count > 1) {
                                    DBProvider.db.removePickupPart(element.orderNumber);
                                    DBProvider.db.insertPickUpPart(element);
                                  }
                                  globals.pickupList.remove(element);

                                  //
                                });
                              });

                              setState(() {
                                /*globals.pickupList.clear();
                                DBProvider.db.deleteAllPickupPart();*/
                                showToast('Success! All items were removed', context: context, axis: Axis.horizontal, alignment: Alignment.center, position: StyledToastPosition.center);
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: verticalPixel * 2),
                              height: verticalPixel * 5,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Color(0xfff30a37),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(top: verticalPixel * 0.3),
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
                            ),
                          ),
                          pickupCard(position),
                        ],
                      );
                      position = 0;
                    }
                    if (position == 0 && globals.pickupList.length > 2) {
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                globals.pickupList.clear();
                                showToast('Success! All items were removed', context: context, axis: Axis.horizontal, alignment: Alignment.center, position: StyledToastPosition.center);
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: verticalPixel * 2),
                              height: verticalPixel * 5,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Color(0xfff30a37),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(top: verticalPixel * 0.3),
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
                            ),
                          ),
                          pickupCard(position),
                        ],
                      );
                      position = 0;
                    }

                    return pickupCard(position);
                  },
                  itemCount: globals.pickupList.length + 0,
                ))));
  }

  @override
  void dispose() {
    _pickUpTabBloc = null;
    pickUpPartCount = -1;
    pickUpExternalCount = -1;
    //_focusNode.dispose();
    //pickupScanner.stopScanner();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: (event) {
        if (event.runtimeType.toString() == 'RawKeyDownEvent') {
          //showToast(event.physicalKey.usbHidUsage.toString(), context: context, axis: Axis.horizontal, alignment: Alignment.center, position: StyledToastPosition.center);

          //print(event.physicalKey.debugName);
          //print(event.physicalKey.usbHidUsage);
          if (event.physicalKey.usbHidUsage == 392961) {
            kitScanning = true;
          }
        }
        if (event.runtimeType.toString() == 'RawKeyUpEvent') {
          //showToast(event.physicalKey.usbHidUsage.toString(), context: context, axis: Axis.horizontal, alignment: Alignment.center, position: StyledToastPosition.center);

          kitScanning = false;
          //print(event.physicalKey.usbHidUsage);
          if (event.physicalKey.usbHidUsage == 458792) {
            print('yes');
            if (trackerHolder[0] != '') {
              //Create ticket
              createKit(trackerHolder[0]);
              trackerHolder = ["", ""];
              setState(() {
                createBullet();
              });
            } else {
              showToast('Please scan order number first!', context: context, axis: Axis.horizontal, alignment: Alignment.center, position: StyledToastPosition.center);
            }
          }
        }
      },
      child: StyledToast(
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
        child: GestureDetector(
          onPanUpdate: (details) {
            if (details.delta.dx < 0) {
              // swiping in right direction
              ////print('move to pickup');
              la.moveTo(globals.isDriverMode ? 1 : 2);
            }
            if (details.delta.dx > 0) {
              // swiping in right direction
              ////print('move to pickup');
              la.moveTo(0);
            }
          },
          onTap: () {
            _focusNode.requestFocus();
          },
          child: SingleChildScrollView(
              child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      height: verticalPixel * 65,
                      margin: EdgeInsets.symmetric(horizontal: horizontalPixel * 3.5, vertical: verticalPixel * 1),
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
                              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      /*//print(globals.locationList.length);
                                    if (globals.locationList.length != 0) {
                                      showPickerL();
                                      setState(() {
                                        globals.currentSite = globals.lList[0];
                                      });
                                    } else {
                                      showToast('Fail! No internet connection ', context: context, axis: Axis.horizontal, alignment: Alignment.center, position: StyledToastPosition.center);
                                    }*/
                                    },
                                    child: Container(
                                      height: verticalPixel * 3,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Color(0xff171721),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.only(top: verticalPixel * 0.3),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Text(
                                              '       Total: ' + globals.pickupList.length.toString(),
                                              style: TextStyle(color: Colors.white70, fontSize: 12),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(bottom: 2),
                                              //height: 20,
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  right: BorderSide(color: Colors.white.withOpacity(.5), width: 1.0),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Text(
                                              'Current location: ' + globals.currentSite,
                                              style: TextStyle(color: Colors.white70, fontSize: 12),
                                              overflow: TextOverflow.fade,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  /*globals.pickupList.length > 2
                                    ? Container(
                                        margin: EdgeInsets.symmetric(vertical: verticalPixel * 2),
                                        height: verticalPixel * 5,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Color(0xfff30a37),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(top: verticalPixel * 0.3),
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

                                  globals.pickupList.isNotEmpty
                                      ? getPickUpList()
                                      : Expanded(
                                          child: Padding(
                                              padding: EdgeInsets.fromLTRB(0, 0.0, 0, 0),
                                              child: Align(
                                                  alignment: Alignment.center,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Material(
                                                          color: Colors.transparent,
                                                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                                                            Padding(
                                                                padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    Text(
                                                                      'Scan to add ',
                                                                      style: TextStyle(fontSize: 20.0, color: Colors.white),
                                                                    ),
                                                                    /*Text(
                                                                'pick up ',
                                                                style: TextStyle(fontSize: 20.0, color: Color(0xff9969ff)),
                                                              ),*/
                                                                    GestureDetector(
                                                                      onTap: () {
                                                                        //print(globals.pickupList);
                                                                      },
                                                                      child: Text(
                                                                        'item',
                                                                        style: TextStyle(fontSize: 20.0, color: Colors.white),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ))
                                                          ])),
                                                      MaterialButton(
                                                          elevation: 0,
                                                          //color: Color(0xff7663E9),
                                                          padding: EdgeInsets.all(0),
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                                          onPressed: () async {
                                                            globals.pickupList = await DBProvider.db.getAllPickUpPartResults();
                                                            //print(globals.currentSite);
                                                            showToast('Ding', context: context, axis: Axis.horizontal, alignment: Alignment.center, position: StyledToastPosition.center);
                                                            setState(() {});
                                                          },
                                                          child: Ink(
                                                            decoration: const BoxDecoration(
                                                              gradient: LinearGradient(
                                                                colors: [Color(0xff68b3ec), Color(0xff8543de)],
                                                                begin: Alignment.topLeft,
                                                                end: Alignment.bottomRight,
                                                              ),
                                                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                            ),
                                                            child: Padding(
                                                              padding: EdgeInsets.symmetric(vertical: verticalPixel * 1, horizontal: verticalPixel * 5.4),
                                                              child: FittedBox(
                                                                child: Text(
                                                                  'Reload from cache',
                                                                  style: TextStyle(color: Colors.white, fontSize: verticalPixel * 2, fontStyle: FontStyle.normal),
                                                                ),
                                                              ),
                                                            ),
                                                          )),
                                                    ],
                                                  )))),
                                ],
                              )),
                        ),
                      )),
                  Visibility(
                    visible: globals.popup == 0,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPixel * 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: ButtonTheme(
                              height: verticalPixel * 8,
                              minWidth: horizontalPixel * 5,
                              child: RaisedButton(
                                color: Color(0xff2C2C34),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  //side: BorderSide(color: Color(0xff171721)),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                                  child: Text(
                                    'Add',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                onPressed: () async {
                                  setState(() {
                                    globals.popup = 1;
                                  });
                                  showCupertinoModalPopup(context: context, builder: (BuildContext context) => Pop(1)).then((value) {
                                    SystemChrome.restoreSystemUIOverlays();
                                    setState(() {
                                      globals.popup = 0;
                                    });
                                  });
                                  //print(globals.pickupList.toString());
                                },
                              ),
                            ),
                          ),
                          Visibility(
                            visible: globals.pickupList.length > 0,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: horizontalPixel * 3),
                              child: ButtonTheme(
                                height: verticalPixel * 8,
                                minWidth: horizontalPixel * 20,
                                child: RaisedButton(
                                  color: Color(0xff63a2ff),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: horizontalPixel * 12, vertical: 4),
                                    child: Text(
                                      'SEND',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  onPressed: () async {
                                    /*try {
                                    globals.pickupList.forEach((element) async {
                                      await _generateTransactionList(element);
                                      if (globals.responseCode == 200) {
                                        //print('globals response is [1]' + globals.responseCode.toString());
                                        globals.deliveryList.add(element);
                                      } else {
                                        showToast('Fail! No internet connection. (E-302)', context: context, axis: Axis.horizontal, alignment: Alignment.center, position: StyledToastPosition.center);
                                      }

                                      //SEND ITEM HERE
                                    });

                                    showToast('Success!', context: context, axis: Axis.horizontal, alignment: Alignment.center, position: StyledToastPosition.center);
                                    setState(() {
                                      //print('globals response is [2]' + globals.responseCode.toString());
                                      globals.pickupList = globals.responseCode == 200 ? [] : globals.pickupList;
                                    });
                                  } catch (e) {
                                    showToast('Fail! ' + e.toString(), context: context, axis: Axis.horizontal, alignment: Alignment.center, position: StyledToastPosition.center);
                                  }*/
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    List toRemove = [];

                                    for (PickUpPart element in globals.pickupList) {
                                      var result = await _generateTransactionList(element);
                                      print(result);
                                      if (result) {
                                        print('send successfully [1]. Item add to delivery list');
                                        setState(() {
                                          globals.deliveryList.add(element);
                                          DBProvider.db.insertDeliverPart(element);
                                          toRemove.add(element);
                                          showToast('Success!', context: context, axis: Axis.horizontal, alignment: Alignment.center, position: StyledToastPosition.center);
                                        });
                                      } else {
                                        showToast('Fail! No internet connection. (E-302)', context: context, axis: Axis.horizontal, alignment: Alignment.center, position: StyledToastPosition.center);
                                        break;
                                      }
                                    }

                                    setState(() {
                                      for (PickUpPart item in toRemove) {
                                        globals.pickupList.remove(item);
                                      }
                                      DBProvider.db.deleteAllPickupPart();
                                      _isLoading = false;
                                    });
                                    la.moveTo(globals.selectedTabIndex + 1);
                                  },
                                ),
                              ),
                            ),
                          ),
                          /*Expanded(
                          child: ButtonTheme(
                            height: verticalPixel * 8,
                            minWidth: horizontalPixel * 10,
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
                      height: verticalPixel * 85,
                      child: Center(
                        child: Column(
                          children: [
                            SizedBox(
                              height: verticalPixel * 25,
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

  pickupCard(position) {
    return Slidable(
      actionPane: SlidableScrollActionPane(),
      actions: [
        IconSlideAction(
          caption: 'Remove',
          color: Colors.transparent,
          icon: Icons.delete_forever,
          onTap: () async {
            var count = await DBProvider.db.matchPickupPart(globals.pickupList[position].orderNumber);
            ////print(count.toString());
            setState(() {
              if (count > 1) {
                DBProvider.db.removePickupPart(globals.pickupList[position].orderNumber);
                DBProvider.db.insertPickUpPart(globals.pickupList[position]);
              }
              globals.pickupList.removeAt(position);

              //
            });
          },
        ),
      ],
      child: GestureDetector(
        onTap: () async {
          if (globals.pickupList[position].location == 'Unknown') {
            print(kitScanning.toString());
            print('hello');
            //TODO: show pickup location select widget
            showPickerL(position);
            print(kitScanning.toString());
          } else if (globals.pickupList[position].destination == 'Unknown') {
            showPickerD(position);
          }
        },
        /*onDoubleTap: () {
          if (globals.pickupList[position].tagType != '7') {
            globals.pickupList[position].tagType = '7';
          } else if (globals.pickupList[position].tagType == '7') {
            if (globals.pickupList[position].partNumber == 'KIT-000000-001') {
              globals.pickupList[position].tagType = '6';
            } else {
              globals.pickupList[position].tagType = '5';
            }
          }
          setState(() {
            print(globals.pickupList[position].tagType);
          });
        },*/
        child: Card(
          elevation: 0,
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: EdgeInsets.fromLTRB(0, 0, 0, verticalPixel * 2),
          child: Container(
              height: 110,
              decoration: new BoxDecoration(
                gradient: new LinearGradient(
                    colors: globals.pickupList[position].tagType != '7'
                        ? [Color(0xff6de1ff).withOpacity(.5), Color(0xcb508afd).withOpacity(.5)]
                        : [Color(0xff85edff).withOpacity(.5), Color(0xcb23e3dd).withOpacity(.5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: horizontalPixel * 20,
                        //color: Colors.red,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                padding: EdgeInsets.fromLTRB(0, 12.0, 0.0, 0.0),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                      height: 17,
                                      padding: EdgeInsets.fromLTRB(5.0, 2, 5.0, 0),
                                      margin: EdgeInsets.only(right: 0),
                                      decoration: new BoxDecoration(
                                          color: Color(0xe2d1fffd).withOpacity(.2),
                                          borderRadius: new BorderRadius.only(
                                              topLeft: const Radius.circular(16.0),
                                              topRight: const Radius.circular(16.0),
                                              bottomLeft: const Radius.circular(16.0),
                                              bottomRight: const Radius.circular(16.0))),
                                      child: Text(
                                        " " + (globals.pickupList.length - position).toString() + " ",
                                        style: TextStyle(color: Color(0xe2131313).withOpacity(.2), fontSize: 11.0, fontWeight: FontWeight.bold),
                                      )),
                                )),
                            SizedBox(
                              height: verticalPixel * .5,
                            ),
                            Container(
                                //padding: EdgeInsets.fromLTRB(20, 0, 24.0, 0.0),
                                child: Align(alignment: Alignment.center, child: Text('Order', textAlign: TextAlign.center, style: const TextStyle(color: const Color(0xffffffff), fontSize: 11.0)))),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: horizontalPixel * 1,
                      ),
                      Container(
                        width: horizontalPixel * 60,
                        //color: Colors.red,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                padding: EdgeInsets.fromLTRB(0.0, 12, 0.0, 0),
                                width: 170,
                                child: Text(globals.pickupList[position].orderNumber.replaceAll(new RegExp(r'^0+(?=.)'), ''),
                                    maxLines: 1, overflow: TextOverflow.clip, textAlign: TextAlign.left, style: const TextStyle(color: const Color(0xffffffff), fontSize: 16.0))),
                            SizedBox(
                              height: verticalPixel * .5,
                            ),
                          ],
                        ),
                      ),
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
                              Text(globals.pickupList[position].location != null ? globals.pickupList[position].location : "",
                                  style: TextStyle(color: Color(0xff0e0935).withOpacity(.5), fontWeight: FontWeight.w400, fontSize: 11.0))
                            ],
                          ),
                          Icon(
                            Icons.sync_alt,
                            size: verticalPixel * 2,
                            color: Colors.white70.withOpacity(.3),
                          ),
                          Column(
                            children: <Widget>[
                              Text("Destination", style: const TextStyle(color: const Color(0xff241835), fontWeight: FontWeight.w400, fontStyle: FontStyle.normal, fontSize: 13.0)),
                              globals.pickupList[position].destination == null
                                  ? Text("")
                                  : Text(globals.pickupList[position].destination, style: TextStyle(color: Color(0xff0e0935).withOpacity(.5), fontWeight: FontWeight.w400, fontSize: 11.0))
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

  _sendToServer(TransactionRequest transactionRequest) async {
    try {
      final response = await http.post(
        Uri.parse(globals.baseUrl + '/transaction/'),
        headers: <String, String>{'Content-Type': 'application/json', 'Authorization': 'Basic cmtoYW5kaGVsZGFwaTppMjExVTI7'},
        body: jsonEncode(transactionRequest.toJson()),
      );
      //print(response.statusCode);
      globals.responseCode = response.statusCode;

      //print(transactionRequest.toString());
      //print('finish');
      return true;
    } catch (E) {
      //print('fail to send to server');
      return false;
    }
  }

  _generateTransactionList(pickUpPart) async {
    //print('generate transaction');
    //print(pickUpPart.toString());

    TransactionRequest transactionRequest = TransactionRequest();

    transactionRequest.handHeldId = 'Android_TestDevice';

    transactionRequest.location = pickUpPart.location;

    transactionRequest.status = 'pickup';
    transactionRequest.user = globals.user != null ? globals.user : 'testtest';

    transactionRequest.packages = [getPackageFromPickUpPart(pickUpPart)];
    print(transactionRequest.toString());

    //_transactionRequestItems.add(transactionRequest);
    var sendResult = await _sendToServer(transactionRequest);
    //print('result is' + sendResult.toString());
    return sendResult;
  }

  int selectedValue;
  showPickerL(int position) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return CupertinoPicker(
            backgroundColor: Colors.white,
            onSelectedItemChanged: (value) {
              setState(() {
                selectedValue = value;
                globals.pickupList[position].location = globals.lList[value];
              });
            },
            itemExtent: 32.0,
            children: globals.locationList,
          );
        });
  }

  showPickerD(int position) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return CupertinoPicker(
            backgroundColor: Colors.white,
            onSelectedItemChanged: (value) {
              setState(() {
                selectedValue = value;
                globals.pickupList[position].destination = globals.lList[value];
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
