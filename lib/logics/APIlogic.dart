import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:zebra_trackaware/globals.dart' as globals;

/*_sendToServer(TransactionRequest transactionRequest, {String address: '/transaction/'}) async {
  try {
    final response = await http.post(
      Uri.parse(globals.baseUrl + address),
      headers: <String, String>{'Content-Type': 'application/json', 'Authorization': 'Basic cmtoYW5kaGVsZGFwaTppMjExVTI7'},
      body: jsonEncode(transactionRequest.toJson()),
    );
    print(globals.baseUrl + address);
    print(response.statusCode);
    print(transactionRequest.toString());

    return true;
  } catch (E) {
    print('SEND TO SERVER ERROR' + E.toString());
    return false;
  }
}*/
/*

pickupTrans(package) {
  print('generate transaction');
  print(package.toString());

  TransactionRequest transactionRequest = TransactionRequest();

  transactionRequest.handHeldId = 'Android_TestDevice';
  transactionRequest.id = 232;

  transactionRequest.location = package.location;

  transactionRequest.status = 'pickup';
  transactionRequest.user = globals.user != null ? globals.user : 'testtest';

  transactionRequest.packages = [getPackageFromPickUpPart(package)];
  print(transactionRequest.toString());

  //_transactionRequestItems.add(transactionRequest);
  _sendToServer(transactionRequest);
}

deliTrans(package) async {
  //print('generate transaction');
  //print(package.toString());

  TransactionRequest transactionRequest = TransactionRequest();

  transactionRequest.handHeldId = 'Android_TestDevice';
  transactionRequest.id = 232;
  transactionRequest.location = package.destination;
  transactionRequest.status = 'delivery';
  transactionRequest.user = globals.user != null ? globals.user : 'testtest';
  transactionRequest.receiverSignature = package.receiverSignature != null ? package.receiverSignature : 'Not available';

  transactionRequest.packages = [getPackageFromPickUpPart(package)];
  log(transactionRequest.toString());

  //_transactionRequestItems.add(transactionRequest);
  var sendResult = await _sendToServer(transactionRequest);
  return sendResult;
}

arriveAPI() async {
  TransactionRequest transactionRequest = TransactionRequest();

  transactionRequest.handHeldId = 'Android_TestDevice';

  transactionRequest.location = globals.currentSite;
  transactionRequest.status = 'arrive';
  transactionRequest.user = globals.user != null ? globals.user : 'testtest';

  print(transactionRequest.toString());

  //_transactionRequestItems.add(transactionRequest);
  var sendResult = await _sendToServer(transactionRequest, address: '/observe/');
  return sendResult;
}

departAPI() async {
  TransactionRequest transactionRequest = TransactionRequest();

  transactionRequest.handHeldId = 'Android_TestDevice';

  transactionRequest.location = globals.lastLocation;
  transactionRequest.status = 'depart';
  transactionRequest.user = globals.user != null ? globals.user : 'testtest';

  print(transactionRequest.toString());

  //_transactionRequestItems.add(transactionRequest);
  var sendResult = await _sendToServer(transactionRequest, address: '/observe/');
  return sendResult;
}

_sendLoc(location, {String address: '/transaction/'}) async {
  try {
    final response = await http.post(
      Uri.parse(globals.baseUrl + address),
      headers: <String, String>{'Content-Type': 'application/json', 'Authorization': 'Basic cmtoYW5kaGVsZGFwaTppMjExVTI7'},
      body: jsonEncode(location),
    );
    print(globals.baseUrl + address);
    print(response.statusCode);

    return true;
  } catch (E) {
    print('SEND TO SERVER ERROR' + E.toString());
    return false;
  }
}

locationAPI(currentLocation, deviceIdValue, _userName) async {
  print('start');
  print(DateTime.now().millisecondsSinceEpoch.toString());
  String location = getLocationRequest(currentLocation, deviceIdValue, _userName);
  print(location);
  var sendResult = await _sendLoc(location, address: '/geolocation/');
  print(sendResult);
  return sendResult;
}

class LocResponse {
  String deviceId;
  String username;
  String latitude;
  String longitude;
  String sourceTime;

  LocResponse(this.deviceId, this.username, this.latitude, this.longitude, this.sourceTime);
}

String getLocationRequest(Position currentLocation, String deviceIdValue, String userName) {
  print(globals.user);
  String result = "[" +
      "{" +
      "Deviceid='" +
      deviceIdValue +
      "',Username:" +
      "'" +
      globals.user +
      "'" +
      ", Latitude: '" +
      currentLocation.latitude.toString() +
      "', Longitude='" +
      currentLocation.longitude.toString() +
      "',Altitude='" +
      currentLocation.altitude.toString() +
      "',Sourcetime='" +
      DateTime.now().millisecondsSinceEpoch.toString() +
      "'}" +
      "]";
  print(result);

  return result;
}
*/

/// LOGIN
///
///
Future userLogin(String _userName, String _password) async {
  final loginUrl = Uri.parse(globals.baseUrl + '/mobiletransaction/userauth');

  print("Login Url : " + loginUrl.toString());
  String basicAuth = 'Basic ' + base64Encode(utf8.encode(globals.serverUserName + ':' + globals.serverPassword));

  var loginResponse = await http.post(loginUrl, headers: {'authorization': basicAuth}, body: {'user': _userName, 'password': _password});
  final loginResponseJson = jsonDecode(loginResponse.body);
  print("LoginResponse ***:" + loginResponseJson.toString());
  return loginResponseJson['message'];
}
