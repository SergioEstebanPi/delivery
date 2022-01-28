import 'dart:convert';
import 'dart:io';

import 'package:delivery/api/environment.dart';
import 'package:delivery/models/mercado_pago_document_type.dart';
import 'package:delivery/models/mercado_pago_payment_method_installments.dart';
import 'package:delivery/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MercadoProvider {

  String? _urlMercadoPago = 'api.mercadopago.com';
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

      final url = Uri.https(_urlMercadoPago!, '/v1/identification_types');

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

  Future<MercadoPagoPaymentMethodInstallments?> getInstallments(
      String bin, double amount
      ) async {
    try {
      print('consuming mercadopago');

      final url = Uri.https(_urlMercadoPago!, '/v1/payment_methods/installments', {
        'bin': bin,
        'amount': '${amount}'
      });

      final res = await http.get(url, headers: {
        HttpHeaders.authorizationHeader: 'Bearer ${_mercadoPagoCredentials.accessToken}',
      });
      final data = json.decode(res.body);
      print('data mercadopago: ${data}');
      final result = MercadoPagoPaymentMethodInstallments.fromJsonList(data);
      return result.installmentList.first;

    } catch(e){
      print('Error: $e');
      return null;
    }
  }

  Future<http.Response?> createCardToken({
    required String cvv,
    required String expirationYear,
    required int expirationMonth,
    required String cardNumber,
    required String documentNumber,
    required String documentId,
    required String cardHolderName
  }) async {
    try{
      final url = Uri.https(_urlMercadoPago!, '/v1/card_tokens');

      // identification for Colombia, for Mexico is not required
      final body = {
        'securityCode': cvv,
        'cardExpirationYear': expirationYear,
        'cardExpirationMonth': expirationMonth,
        'cardNumber': cardNumber,
        'cardholderName': {
          'identification': {
            'number': documentNumber,
            'type': documentId
          },
          'name': cardHolderName
        }
      };

      final res = await http.post(url, headers: {
        HttpHeaders.authorizationHeader: 'Bearer ${_mercadoPagoCredentials.accessToken}',
      }, body: json.encode(body));

      return res;

    } catch(e){
      print('Error $e');
      return null;
    }
  }

}