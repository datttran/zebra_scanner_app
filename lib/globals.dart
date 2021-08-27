library trackaware_shipper.globals;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:zebra_trackaware/utils/strings.dart';

bool isDriverMode = false;
bool useToolNumber = true;
bool isTesting = true;
String tenderProductionPartsDispName = Strings.TENDER_PRODUCTION_PARTS;
String tenderExternalPackagesDispName = Strings.TENDER_EXTERNAL_PACKAGES;
String pickUpProductionPartsDispName = Strings.PICKUP_PRODUCTION_PARTS;
String pickUpExternalPackagesDispName = Strings.PICKUP_EXTERNAL_PACKAGES;
String departDispName = Strings.departTitle;
String arriveDispName = Strings.arriveTitle;

String selectedKey = "";
String selectedName = "";

int selectedTabIndex = 0;
double max = 10;
String selectedLoc = "";
bool showNextButton = false;
bool refreshDelivery = false;

//String baseUrl = "http://13.57.192.146/trackaware/handheldapi";
String baseUrl = "http://54.241.5.83/trackaware/handheldapi"; // na1
//String baseUrl = "http://54.241.28.203/trackaware/handheldapi"; // na3
//String baseUrl = "http://50.18.108.22/trackaware/handheldapi"; // na2

String serverUserName = "rkhandheldapi";
//String serverPassword = "TrackAware11";
String serverPassword = "i211U2;";

String tabScanPosName = "";
String scanOption = "";
String pickScanOption = "";

String orderNumber = "";
String partNumber = "";
String refNumber = "";
String toolNumber = "";
String trackingNumber = "";

String navFrom = "";
String barCode = "";
String scannedCode = 'Empty';

bool isPickUpOnTender = false;

/*PickUpPart selectedPickUpPart;
PickUpExternal selectedPickUpExternal;

TenderParts tenderParts;
TenderExternal tenderExternal;*/

int popup = 0;
String? value;
String? note;
var currentAddress;
Placemark? currentLocation;
var cameras;
var selectedCard = 0;
int delivered = 0;
int tendered = 0;
var receiver;
String? signature;
List? locations;
var touchMode = false;
String? user;
//List
List tenderList = [];
List pickupList = [];
List deliveryList = [];
Color themeBackground = Color(0xfff0ccff);

//Future
var futureLocation;
var originLocations;
List lList = [];
List<Widget> locationList = []; // List of text locations
var destinationLocations;

String currentSite = 'Unknown'; // pickup site in code
List locationMap = [
//Loc(id: 'CA4', lat: 37.3661483, long: -121.8677783),
  //Loc(id: 'CA5', lat: 37.3661, long: -121.8676),
  /*Loc(id: 'CA3', lat: 37.40037, long: -121.9858283),

  Loc(id: 'CA8', lat: 37.3595267, long: -122.0138174),
  Loc(id: 'CA4', lat: 37.3723747, long: -121.8729188),*/
];
List<Placemark>? placeMarks;
double? currentLong;
double? currentLat;
String adminPassword = '';

int? responseCode;
String lengthLimit = '11';

String lastLocation = 'Unknown';
int sensitivity = 100; // range of a location
bool kitScanning = false;
bool filter = false;

//PARSE
int orderLimit = 12;
int containerLimit = 9;
int trackingLimit = 15;
