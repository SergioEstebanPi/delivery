import 'dart:convert';
import 'dart:io';

import 'package:delivery/api/environment.dart';
import 'package:delivery/models/order.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class EpaycoProvider {

  String? _urlEpayco = 'apify.epayco.co';
  final _epaycoCredentials = Environment.epaycoCredentials;

  BuildContext? context;
  User? user;
  String? _urlApi = Environment.API_DELIVERY;

  Future? init(BuildContext context, User user){
    this.context = context;
    this.user = user;
  }

  Future<http.Response?> createPayment({
    required String cardNumber,
    required String expYear,
    required String expMonth,
    required String cvc,
    required String documentNumber,
    required String documentId,
    required String cardHolderName,
    required Order order,
    /*{
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
  }*/
  }
  ) async {
    try{
      print('consuming Epayco createPayment');

      final url = Uri.http(_urlApi!, '/api/payments/createEpaycoPay');
      Map<String, String> headers = {
        'Content-type': 'application/json',
        'Authorization': user!.sessionToken!
      };

      /*
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
     */

      order.idUser = user!.id;
      order.idStore = user!.id;

      Map<String, dynamic> body = {
        'number': cardNumber,
        'exp_year': expYear,
        'exp_month': expMonth,
        'cvc': cvc,
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

}