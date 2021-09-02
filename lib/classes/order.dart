class Order {
  List<Results>? results;

  Order({this.results});

  Order.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      json['results'].forEach((v) {
        results!.add(new Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.results != null) {
      data['results'] = this.results!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Results {
  String? container;
  String? order;
  String? tag;
  String? user;
  String? status;
  String? type;
  String? dest;
  String? origin;
  String? priority;
  String? qty;
  String? event;

  Results({this.container, this.order, this.tag, this.user, this.status, this.type, this.dest, this.origin, this.priority, this.qty, this.event});

  Results.fromJson(Map<String, dynamic> json) {
    container = json['container'];
    order = json['order'];
    tag = json['tag'];
    user = json['user'];
    status = json['status'];
    type = json['type'];
    dest = json['dest'];
    origin = json['origin'];
    priority = json['priority'];
    qty = json['qty'];
    event = json['event'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['container'] = this.container;
    data['order'] = this.order;
    data['tag'] = this.tag;
    data['user'] = this.user;
    data['status'] = this.status;
    data['type'] = this.type;
    data['dest'] = this.dest;
    data['origin'] = this.origin;
    data['priority'] = this.priority;
    data['qty'] = this.qty;
    data['event'] = this.event;
    return data;
  }

  @override
  String toString() {
    // TODO: implement toString
    return ' | container: ' + container.toString() + ' | tag: ' + tag.toString();
  }
}
