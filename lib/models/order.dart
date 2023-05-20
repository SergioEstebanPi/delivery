import 'dart:convert';

import 'package:delivery/models/address.dart';
import 'package:delivery/models/product.dart';
import 'package:delivery/models/user.dart';

Order orderFromJson(String str) => Order.fromJson(json.decode(str));

String orderToJson(Order data) => json.encode(data.toJson());

class Order {

  String? id;
  String? idUser;
  String? idClient;
  String? idDelivery;
  String? idAddress;
  String? status;
  double? lat;
  double? lng;
  int? timestamp;
  List<Product> products = [];
  List<Order> toList = [];
  User? client;
  Address? restaurant;
  Address? address;
  User? delivery;

  Order({
    this.id,
    this.idUser,
    this.idClient,
    this.idDelivery,
    this.idAddress,
    this.status,
    this.lat,
    this.lng,
    this.timestamp,
    required this.products,
    this.client,
    this.restaurant,
    this.address,
    this.delivery,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json["id"] is int ? json["id"].toString() : json["id"],
    idUser: json["id_user"],
    idClient: json["id_client"],
    idDelivery: json["id_delivery"],
    idAddress: json["id_address"],
    status: json["status"],
    lat: json["lat"] is String ? double.parse(json["lat"]) : json["lat"],
    lng: json["lng"] is String ? double.parse(json["lng"]) : json["lng"],
    timestamp: json["timestamp"] is String ? int.parse(json["timestamp"]) : json["timestamp"],
    products: json["products"] != null
      ? List<Product>.from(json["products"].map((p) => p is Product
        ? p
        : Product.fromJson(p)))
      : [],
    client: json["client"] is String
        ? userFromJson(json['client'])
        : json["client"]  is User
          ? json["client"]
          : User.fromJson(json["client"] ?? {}),
    address: json["address"] is String
        ? addressFromJson(json['address'])
        : json['address'] is Address
          ? json["address"]
        : Address.fromJson(json["address"] ?? {}),
    restaurant: json["restaurant"] is String
        ? addressFromJson(json['restaurant'])
        : json["restaurant"]  is Address
        ? json["restaurant"]
        : Address.fromJson(json["restaurant"] ?? {}),
    delivery: json["delivery"] is String
        ? userFromJson(json['delivery'])
        : json['delivery'] is User
          ? json["delivery"]
          : User.fromJson(json["delivery"] ?? {}),
  );

  Order.fromJsonList(List<dynamic> jsonList) {
    if(jsonList == null){
      return;
    }

    jsonList.forEach((item) {
      Order order = Order.fromJson(item);
      toList.add(order);
    });
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "id_user": idUser,
    "id_client": idClient,
    "id_delivery": idDelivery,
    "id_address": idAddress,
    "status": status,
    "lat": lat,
    "lng": lng,
    "timestamp": timestamp,
    "products": products,
    "client": client,
    "restaurant": restaurant,
    "address": address,
    "delivery": delivery,
  };
}
