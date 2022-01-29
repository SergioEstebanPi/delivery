import 'dart:convert';
import 'dart:io';

import 'package:delivery/api/environment.dart';
import 'package:delivery/models/mercado_pago_document_type.dart';
import 'package:delivery/models/mercado_pago_payment_method_installments.dart';
import 'package:delivery/models/order.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class MercadoProvider {

  String? _urlMercadoPago = 'api.mercadopago.com';
  final _mercadoPagoCredentials = Environment.mercadoPagoCredentials;

  BuildContext? context;
  User? user;
  String? _urlApi = Environment.API_DELIVERY;

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

  Future<http.Response?> createPayment({
    required String cardId,
    required double transactionAmount,
    required int installments,
    required String paymentMethodId,
    required String paymentTypeId,
    required String issuerId,
    required String emailCustomer,
    required String token,
    required String identificationType,
    required String identificationNumber,
    required Order order,
  }) async {
    try{
      print('consuming mercadopago');

      final url = Uri.http(_urlApi!, '/api/payments/createPay');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': user!.sessionToken!
      };

      Map<String, dynamic> body = {
        'description': "Delivery",
        'transaction_amount': transactionAmount,
        'installments': installments,
        'payment_method_id': paymentMethodId,
        'payment_type_id': paymentTypeId,
        'card_token': token,
        'issuer_id': issuerId,
        'payer': {
          'email': emailCustomer,
          'identification': {
            'type': identificationType,
            'number': identificationNumber
          }
        },
        'order': order
     };

      String bodyParams = json.encode(body);
      final res = await http.post(url, headers: headers, body: bodyParams);

      if(res.statusCode == 401){
        Fluttertoast.showToast(msg: 'Sesion expirada');
        SharedPref().logout(context!, idUser: user!.id);
      }

      return res;

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
        'cardholder': {
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