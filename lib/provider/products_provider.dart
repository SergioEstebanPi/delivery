import 'dart:convert';
import 'dart:io';

import 'package:delivery/api/environment.dart';
import 'package:delivery/models/product.dart';
import 'package:delivery/models/response_api.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/utils/shared_pref.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class ProductsProvider {

  String _url = Environment.API_DELIVERY;
  String _api = '/api/products';

  late BuildContext? context;
  User? sessionUser;

  Future init(BuildContext? context, {User? sessionUser}) async {
    this.context = context;
    this.sessionUser = sessionUser;
  }

  Future<List<Product>> findByCategoryId(String idCategory) async {
    try{
      Uri uri = Uri.http(_url, '$_api/findByCategoryId/$idCategory');
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

      final data = json.decode(res.body); // categorias
      Product product = Product.fromJsonList(data);
      return product.toList;
    } catch(error){
      print('Error $error');
      return [];
    }
  }

  Future<List<Product>> findByCategoryAndProductName(String idCategory, String productName) async {
    try{
      Uri uri = Uri.http(_url, '$_api/findByCategoryAndProductName/$idCategory/$productName');
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

      final data = json.decode(res.body); // categorias
      Product product = Product.fromJsonList(data);
      return product.toList;
    } catch(error){
      print('Error $error');
      return [];
    }
  }

  Future<Stream?> create(Product product, List<File> images) async {
    try {
      Uri uri = Uri.http(_url, '$_api/create');
      final request = http.MultipartRequest("POST", uri);
      request.headers['Authorization'] = sessionUser!.sessionToken!;

      if(images != null){
        for(int i=0; i < images.length; i++){
          request.files.add(http.MultipartFile(
              'image',
              http.ByteStream(images[i].openRead().cast()),
              await images[i].length(),
              filename: basename(images[i].path)
          ));
        }
      }

      request.fields['product'] = json.encode(product);
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

}