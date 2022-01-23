import 'dart:convert';

import 'package:delivery/api/environment.dart';
import 'package:delivery/models/order.dart';
import 'package:delivery/models/response_api.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class OrdersProvider {

  String _url = Environment.API_DELIVERY;
  String _api = '/api/orders';

  late BuildContext? context;
  User? sessionUser;

  Future init(BuildContext? context, {User? sessionUser}) async {
    this.context = context;
    this.sessionUser = sessionUser;
  }

  Future<List<Order>> getByStatus(String status) async {
    try{
      Uri uri = Uri.http(_url, '$_api/findByStatus/${status}');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': sessionUser!.sessionToken!
      };
      print("URI $uri");
      print("headers $headers");

      final res = await http.get(uri, headers: headers);
      if(res.statusCode == 401){
        Fluttertoast.showToast(msg: 'Sesion expirada');
        SharedPref().logout(context!, idUser: sessionUser!.id);
      }

      final data = json.decode(res.body); // ordenes
      Order order = Order.fromJsonList(data);
      return order.toList;
    } catch(error){
      print('Error $error');
      return [];
    }
  }


  Future<ResponseApi> create(Order order) async {
    try {
      Uri uri = Uri.http(_url, '$_api/create');
      String bodyParams = json.encode(order);
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': sessionUser!.sessionToken!
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

  Future<ResponseApi> updateToDispatched(Order order) async {
    try {
      Uri uri = Uri.http(_url, '$_api/updateToDispatched');
      String bodyParams = json.encode(order);
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': sessionUser!.sessionToken!
      };
      print("URI $uri");
      print("bodyParams $bodyParams");
      print("headers $headers");
      final res = await http.put(uri, headers: headers, body: bodyParams);
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