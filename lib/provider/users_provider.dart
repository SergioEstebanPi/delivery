import 'dart:convert';
import 'dart:io';

import 'package:delivery/api/environment.dart';
import 'package:delivery/models/response_api.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class UsersProvider {

  String _url = Environment.API_DELIVERY;
  String _api = '/api/users';

  late BuildContext? context;
  User? sessionUser;

  Future init(BuildContext? context, {User? sessionUser}) async {
    this.context = context;
    this.sessionUser = sessionUser;
  }

  Future<User?> getById(String id) async {
    try {
      Uri uri = Uri.http(_url, '$_api/findById/$id');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': sessionUser!.sessionToken!
      };
      final res = await http.get(uri, headers: headers);
      if(res.statusCode == 401){ // no autorizado
        Fluttertoast.showToast(msg: 'Tu sesion ha expirado');
        new SharedPref().logout(context!);
      }

      final data = json.decode(res.body);
      User user = User.fromJson(data);
      return user;
    } catch(e){
      print('Error $e');
      return null;
    }
  }

  Future<List<User>> getDeliveryMen() async {
    try {
      Uri uri = Uri.http(_url, '$_api/findDeliveryMen');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': sessionUser!.sessionToken!
      };
      final res = await http.get(uri, headers: headers);
      if(res.statusCode == 401){ // no autorizado
        Fluttertoast.showToast(msg: 'Tu sesion ha expirado');
        new SharedPref().logout(context!);
      }

      final data = json.decode(res.body);
      User user = User.fromJsonList(data);
      return user.toList;
    } catch(e){
      print('Error $e');
      return [];
    }
  }

  Future<Stream?> createWithImage(User user, File image) async {
    try {
      Uri uri = Uri.http(_url, '$_api/register');
      final request = http.MultipartRequest("POST", uri);

      if(image != null) {
        request.files.add(http.MultipartFile(
          'image',
          http.ByteStream(image.openRead().cast()),
          await image.length(),
          filename: basename(image.path)
        ));
      }

      request.fields['user'] = json.encode(user);
      final response = await request.send();
      return response.stream.transform(utf8.decoder);
    } catch(e){
      Map<String, dynamic> res = {
        "message": "",
        "error": "Error ${e}",
        "success": false,
        "data": null,
      };
      ResponseApi responseApi = ResponseApi.fromJson(res);
      print('res: ${res}');
      return null;
    }
  }

  Future<Stream?> update(User user, File? image) async {
    try {
      Uri uri = Uri.http(_url, '$_api/update');
      final request = http.MultipartRequest("PUT", uri);
      print('actualizar con token: ${sessionUser!.sessionToken}');
      print('el usuario: ${user.toJson()}');
      request.headers['Authorization'] = sessionUser!.sessionToken!;

      if(image != null) {
        request.files.add(http.MultipartFile(
            'image',
            http.ByteStream(image.openRead().cast()),
            await image.length(),
            filename: basename(image.path)
        ));
      }

      request.fields['user'] = json.encode(user);
      final response = await request.send();
      if(response.statusCode == 401) {
        Fluttertoast.showToast(msg: 'Tu sesion ha expirado');
        new SharedPref().logout(context!, idUser: user.id);
      }

      return response.stream.transform(utf8.decoder);
    } catch(e){
      Map<String, dynamic> res = {
        "message": "",
        "error": "Error ${e}",
        "success": false,
        "data": null,
      };
      ResponseApi responseApi = ResponseApi.fromJson(res);
      print('res: ${res}');
      return null;
    }
  }

  Future<ResponseApi> create(User user) async {
    try {
      Uri uri = Uri.http(_url, '$_api/register');
      String bodyParams = json.encode(user);
      Map<String, String> headers = {
        'Content-type': 'application/json'
      };
      print("URI $uri");
      print("bodyParams $bodyParams");
      print("headers $headers");
      final res = await http.post(uri, headers: headers, body: bodyParams);
      final data = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;
    } catch(e) {
      Map<String, dynamic> res = {
        "message": "",
        "error": "Error ${e}",
        "success": false,
        "data": null,
      };
      ResponseApi responseApi = ResponseApi.fromJson(res);
      return responseApi;
    }
  }

  Future<ResponseApi> updateNotificationToken(String idUser, String token) async {
    try {
      Uri uri = Uri.http(_url, '$_api/updateNotificationToken');
      String bodyParams = json.encode({
        'id': idUser,
        'notification_token': token
      });
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': sessionUser!.sessionToken!
      };
      print("URI $uri");
      print("bodyParams $bodyParams");
      print("headers $headers");
      final res = await http.put(uri, headers: headers, body: bodyParams);

      if(res.statusCode == 401){ // no autorizado
        Fluttertoast.showToast(msg: 'Tu sesion ha expirado');
        new SharedPref().logout(context!);
      }

      final data = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;
    } catch(e) {
      Map<String, dynamic> res = {
        "message": "",
        "error": "Error ${e}",
        "success": false,
        "data": null,
      };
      ResponseApi responseApi = ResponseApi.fromJson(res);
      return responseApi;
    }
  }

  Future<ResponseApi> login(email, password) async {
    try {
      Uri uri = Uri.http(_url, '$_api/login');
      String bodyParams = json.encode({"email": email, "password": password});
      Map<String, String> headers = {
        'Content-type': 'application/json'
      };
      print("URI $uri");
      print("bodyParams $bodyParams");
      print("headers $headers");
      final res = await http.post(uri, headers: headers, body: bodyParams);
      final data = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;
    } catch(e) {
      Map<String, dynamic> res = {
        "message": "",
        "error": "Error ${e}",
        "success": false,
        "data": null,
      };
      ResponseApi responseApi = ResponseApi.fromJson(res);
      return responseApi;
    }
  }

  Future<ResponseApi> logout(String idUser) async {
    try {
      Uri uri = Uri.http(_url, '$_api/logout');
      String bodyParams = json.encode({"id": idUser});
      Map<String, String> headers = {
        'Content-type': 'application/json'
      };
      print("URI $uri");
      print("bodyParams $bodyParams");
      print("headers $headers");
      final res = await http.post(uri, headers: headers, body: bodyParams);
      final data = json.decode(res.body);
      ResponseApi responseApi = ResponseApi.fromJson(data);
      return responseApi;
    } catch(e) {
      Map<String, dynamic> res = {
        "message": "",
        "error": "Error ${e}",
        "success": false,
        "data": null,
      };
      ResponseApi responseApi = ResponseApi.fromJson(res);
      return responseApi;
    }
  }
}