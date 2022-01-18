import 'dart:convert';
import 'dart:io';

import 'package:delivery/api/environment.dart';
import 'package:delivery/models/product.dart';
import 'package:delivery/models/response_api.dart';
import 'package:delivery/models/user.dart';

import 'package:flutter/material.dart';
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