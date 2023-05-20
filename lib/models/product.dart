import 'dart:convert';

Product productFromJson(String str) => Product.fromJson(json.decode(str));

String productToJson(Product data) => json.encode(data.toJson());

class Product {

  String? id;
  String? id_user;
  String? name;
  String? description;
  String? image1;
  String? image2;
  String? image3;
  double? price;
  int? id_category;
  int? quantity;
  List<Product> toList = [];

  Product({
    this.id,
    this.id_user,
    this.name,
    this.description,
    this.image1,
    this.image2,
    this.image3,
    this.price,
    this.id_category,
    this.quantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"] is int
        ? json["id"].toString()
        : json["id"],
    id_user: json["id_user"] is int
        ? json["id_user"].toString()
        : json["id_user"],
    name: json["name"],
    description: json["description"],
    image1: json["image1"],
    image2: json["image2"],
    image3: json["image3"],
    price: json["price"] is String 
      ? double.parse(json["price"])
      : isInteger(json["price"])
        ? json["price"].toDouble()
        : json["price"],
    id_category: json["id_category"] is String
        ? int.parse(json["id_category"])
        : json["id_category"],
    quantity: json["quantity"],
  );

  Product.fromJsonList(List<dynamic> jsonList) {
    if(jsonList == null){
      return;
    }

    jsonList.forEach((item) {
      Product product = Product.fromJson(item);
      toList.add(product);
    });
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "id_user": id_user,
    "name": name,
    "description": description,
    "image1": image1,
    "image2": image2,
    "image3": image3,
    "price": price,
    "id_category": id_category,
    "quantity": quantity,
  };

  static bool isInteger(num value) => value is int || value == value.roundToDouble();
}