// To parse this JSON data, do
//
//     final tenderExternal = tenderExternalFromJson(jsonString);

import 'dart:convert';

PickUpPart pickUpPartFromJson(String str) => PickUpPart.fromJson(json.decode(str));

String pickUpPartToJson(PickUpPart data) => json.encode(data.toJson());

//todo - add is_scanned item and verify scan
class PickUpPart {
  int? id;
  String? quantity;
  String? location;
  String? destination;
  String? orderNumber;
  String? partNumber;
  String? toolNumber;
  String? receivedBy;
  String? priority;
  String? receiverSignature;
  int? scanTime;
  int? isSynced;
  int? isScanned;
  int? keepScannedValues;
  int? isDelivered;
  bool? isSelected;
  String? tagType;

  PickUpPart(
      {this.id,
      this.quantity,
      this.location,
      this.destination,
      this.orderNumber,
      this.partNumber,
      this.toolNumber,
      this.receivedBy,
      this.priority,
      this.receiverSignature,
      this.scanTime,
      this.isSynced,
      this.isScanned,
      this.isDelivered,
      this.keepScannedValues,
      this.isSelected,
      this.tagType});
  @override
  String toString() {
    return toJson().toString();
  }

  factory PickUpPart.fromJson(Map<String, dynamic> json) => PickUpPart(
        id: json["id"],
        quantity: json["quantity"],
        location: json["location"],
        destination: json["dest_location"],
        orderNumber: json["order_number"],
        partNumber: json["part_number"],
        toolNumber: json["tool_number"],
        receivedBy: json["ReceivedBy"],
        priority: json["Priority"],
        receiverSignature: json["ReceiverSignature"],
        scanTime: json["scan_time"],
        isSynced: json["is_synced"],
        isScanned: json["is_scanned"],
        isDelivered: json["is_delivered"],
        keepScannedValues: json["keep_scanned_values"],
        tagType: json["tag_type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "quantity": quantity,
        "location": location,
        "dest_location": destination,
        "order_number": orderNumber,
        "part_number": partNumber,
        "tool_number": toolNumber,
        "ReceivedBy": receivedBy,
        "Priority": priority,
        "ReceiverSignature": receiverSignature,
        "scan_time": scanTime,
        "is_synced": isSynced,
        "is_scanned": isScanned,
        "is_delivered": isDelivered,
        "keep_scanned_values": keepScannedValues,
        "tag_type": tagType,
      };
}
