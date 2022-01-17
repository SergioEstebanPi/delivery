
import 'dart:convert';

Category categoryFromJson(String str) => Category.fromJson(json.decode(str));

String welcomeToJson(Category data) => json.encode(data.toJson());

class Category {
  String? id;
  String? name;
  String? description;

  Category({
    this.id,
    this.name,
    this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"],
    name: json["name"],
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
  };
}