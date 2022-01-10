import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  String? id;
  String name;
  String lastname;
  String email;
  String phone;
  String? image;
  String password;
  String? sessionToken;

  User({
    this.id,
    required this.name,
    required this.lastname,
    required this.email,
    required this.phone,
    this.image,
    required this.password,
    this.sessionToken,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"] ? json["id"] : "",
    name: json["name"],
    lastname: json["lastname"],
    email: json["email"],
    phone: json["phone"],
    image: json["image"] ? json["image"] : "",
    password: json["password"],
    sessionToken: json["session_token"] ? json["session_token"] : "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "lastname": lastname,
    "email": email,
    "phone": phone,
    "image": image,
    "password": password,
    "session_token": sessionToken,
  };
}
