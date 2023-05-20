
import 'dart:convert';

Category categoryFromJson(String str) => Category.fromJson(json.decode(str));

String welcomeToJson(Category data) => json.encode(data.toJson());

class Category {
  String? id;
  String? user_id;
  String? name;
  String? description;
  List<Category> toList = [];

  Category({
    this.id,
    this.name,
    this.description,
    this.user_id,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"],
    user_id: json["user_id"],
    name: json["name"],
    description: json["description"],
  );

  Category.fromJsonList(List<dynamic> jsonList) {
    if(jsonList == null){
      return;
    }

    jsonList.forEach((item) {
      Category category = Category.fromJson(item);
      toList.add(category);
    });
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": user_id,
    "name": name,
    "description": description,
  };
}