import 'dart:convert';

import 'package:delivery/api/environment.dart';
import 'package:delivery/models/stripe_transaction_response.dart';
import 'package:delivery/utils/my_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:http/http.dart' as http;

class StripeProvider {

  Map<String, String> headers = {
    'Authorization': 'Bearer ' + Environment.STRIPE_SECRET,
    'Content-Type': 'application/x-www-form-urlencoded'
  };

  BuildContext? context;

  void init(BuildContext? context){
    this.context = context;
    StripePayment.setOptions(StripeOptions(
        publishableKey: Environment.STRIPE_PUBLISHABLEKEY,
        merchantId: 'test',
        androidPayMode: 'test'
      )
    );
  }

  Future<StripeTransactionResponse?> payWithCard(String amount, String currency) async {
    try{
      var paymentMethod =
        await StripePayment.paymentRequestWithCardForm(CardFormPaymentRequest());
      var paymentIntent = await createPaymentIntent(amount, currency);
      var response = await StripePayment.confirmPaymentIntent(PaymentIntent(
          clientSecret: paymentIntent!['client_secret'],
        paymentMethodId: paymentMethod.id
      ));

      if(response.status == 'succeeded'){
        return StripeTransactionResponse(
            message: 'Transaccion exitosa',
            success: true,
            paymentMethod: paymentMethod
        );
      } else {
        return StripeTransactionResponse(
            message: 'Transaccion fallo',
            success: false,
            paymentMethod: paymentMethod
        );
      }

    }catch(e){
      print('Error: $e');
      MySnackbar.show(context!, 'Transaccion fallo: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createPaymentIntent(String amount, String currency) async {
    try{
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      Uri uri = Uri.https('api.stripe.com', 'v1/payment_intents');
      var response = await http.post(uri, body: body, headers: headers);

      return jsonDecode(response.body);

    } catch(e){
      print('Error al crear intent de pagos: $e');
      return null;
    }
  }

}