import 'dart:convert';
import 'dart:io';

import 'package:delivery/api/environment.dart';
import 'package:delivery/models/response_api.dart';
import 'package:delivery/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class UsersProvider {

  String _url = Environment.API_DELIVERY;
  String _api = '/api/users';

  late BuildContext? context;

  Future init(BuildContext? context) async {
    this.context = context;
  }

  Future<User?> getById(String id) async {
    try {
      Uri uri = Uri.http(_url, '$_api/findById/$id');
      Map<String, String> headers = {
        'Content-type': 'application/json'
      };
      final res = await http.get(uri, headers: headers);
      final data = json.decode(res.body);
      User user = User.fromJson(data);
      return user;
    } catch(e){
      print('Error $e');
      return null;
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
      return null;
    }
  }

  Future<Stream?> update(User user, File? image) async {
    try {
      Uri uri = Uri.http(_url, '$_api/update');
      final request = http.MultipartRequest("PUT", uri);

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
}