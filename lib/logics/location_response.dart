import 'package:http/http.dart' as http;
import 'package:zebra_trackaware/globals.dart' as globals;

class LocationResponse {
  int? id;
  double? lat;
  double? long;
  String? code;
  String? description;
  String? loc;

  LocationResponse({this.code, this.description});

  LocationResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    description = json['description'];
    id = json['id'];
    loc = json['loc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['description'] = this.description;
    data['id'] = this.id;
    data['loc'] = this.loc;
    return data;
  }
}

class LocationApiResponse {
  String? message;

  LocationApiResponse({this.message});

  LocationApiResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    return data;
  }
}

fetchLocation() async {
  final response = await http.get(Uri.parse(globals.baseUrl + '/readpoint/'), headers: <String, String>{'Authorization': 'Basic cmtoYW5kaGVsZGFwaTppMjExVTI7'});
  print(response.statusCode);
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.

    return response.body;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load location');
  }
}

class Loc {
  double? lat;
  double? long;
  String? id;

  Loc({this.id, this.lat = 0, this.long = 0});

  @override
  String toString() {
    // TODO: implement toString
    return id! + ' | lat: ' + lat.toString() + ' | long: ' + long.toString();
  }
}
