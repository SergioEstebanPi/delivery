import 'dart:convert';

import 'package:delivery/models/mercado_pago_card_token.dart';
import 'package:delivery/models/mercado_pago_document_type.dart';
import 'package:delivery/models/mercado_pago_installment.dart';
import 'package:delivery/models/mercado_pago_issuer.dart';
import 'package:delivery/models/mercado_pago_payment_method_installments.dart';
import 'package:delivery/models/product.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/provider/mercado_provider.dart';
import 'package:delivery/utils/my_snackbar.dart';
import 'package:delivery/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:http/http.dart';

class ClientPaymentsInstallmentsController {

  BuildContext? context;
  Function? refresh;
  MercadoProvider _mercadoProvider = MercadoProvider();
  User? user;
  SharedPref _sharedPref = SharedPref();

  MercadoPagoCardToken? mercadoPagoCardToken;
  List<Product> selectedProducts = [];
  double totalPayment = 0;
  MercadoPagoPaymentMethodInstallments? installments;
  MercadoPagoIssuer? issuer;
  List<MercadoPagoInstallment> installmentsList = [];
  String? selectedInstallment;

  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    user = User.fromJson(await _sharedPref.read('user'));

    selectedProducts = Product.fromJsonList(await _sharedPref.read('order') ?? []).toList;

    Map<String, dynamic> arguments = ModalRoute
        .of(context)!
        .settings
        .arguments as Map<String, dynamic>;

    mercadoPagoCardToken = MercadoPagoCardToken.fromJsonMap(arguments);
    print('CARD TOKEN ARGS ${mercadoPagoCardToken!.toJson()}');

    _mercadoProvider.init(context, user!);
    getTotalPayment();
    getInstallments();
  }

  void getInstallments() async {
    installments = (await _mercadoProvider.getInstallments(
        mercadoPagoCardToken!.firstSixDigits!,
        totalPayment
    ));

    print('Installments: ${installments!.toJson()}');
    installmentsList = installments!.payerCosts;
    issuer = installments!.issuer;
    refresh!();
  }

  void getTotalPayment(){
    selectedProducts.forEach((p) {
      totalPayment = totalPayment + (p.quantity! * p.price!);
    });
    refresh!();
  }

}