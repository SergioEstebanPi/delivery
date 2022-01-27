import 'dart:convert';
import 'dart:io';

import 'package:delivery/api/environment.dart';
import 'package:delivery/models/mercado_pago_document_type.dart';
import 'package:delivery/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MercadoProvider {

  String? _urlMercadoPago = 'https://api.mercadopago.com';
  final _mercadoPagoCredentials = Environment.mercadoPagoCredentials;

  BuildContext? context;
  User? user;

  Future? init(BuildContext context, User user){
    this.context = context;
    this.user = user;
  }

  Future<List<MercadoPagoDocumentType>?> getIdentificationTypes() async {
    try {
      print('consuming mercadopago');

      final url = Uri.parse(_urlMercadoPago! + '/v1/identification_types');

      final res = await http.get(url, headers: {
        HttpHeaders.authorizationHeader: 'Bearer ${_mercadoPagoCredentials.accessToken}',
      });
      final data = json.decode(res.body);
      print('data mercadopago: ${data}');
      final result = MercadoPagoDocumentType.fromJsonList(data);
      return result.documentTypeList!.toList();

    } catch(e){
      print('Error: $e');
      return null;
    }
  }

}