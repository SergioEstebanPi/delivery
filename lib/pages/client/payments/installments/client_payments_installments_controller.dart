import 'dart:convert';

import 'package:delivery/models/address.dart';
import 'package:delivery/models/mercado_pago_card_token.dart';
import 'package:delivery/models/mercado_pago_document_type.dart';
import 'package:delivery/models/mercado_pago_installment.dart';
import 'package:delivery/models/mercado_pago_issuer.dart';
import 'package:delivery/models/mercado_pago_payment.dart';
import 'package:delivery/models/mercado_pago_payment_method_installments.dart';
import 'package:delivery/models/order.dart';
import 'package:delivery/models/product.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/provider/mercado_provider.dart';
import 'package:delivery/utils/my_snackbar.dart';
import 'package:delivery/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:http/http.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class ClientPaymentsInstallmentsController {

  BuildContext? context;
  Function? refresh;
  MercadoProvider _mercadoProvider = MercadoProvider();
  User? user;
  SharedPref _sharedPref = SharedPref();

  MercadoPagoCardToken? cardToken;
  List<Product> selectedProducts = [];
  double totalPayment = 0;
  MercadoPagoPaymentMethodInstallments? installments;
  MercadoPagoIssuer? issuer;
  List<MercadoPagoInstallment> installmentsList = [];
  String? selectedInstallment;
  Address? address;
  ProgressDialog? _progressDialog;
  String? identificationType;
  String? identificationNumber;
  MercadoPagoPayment? mercadoPagoPayment;
  String? cardId;

  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    user = User.fromJson(await _sharedPref.read('user'));
    address = Address.fromJson(await _sharedPref.read('address'));

    selectedProducts = Product.fromJsonList(await _sharedPref.read('order') ?? []).toList;

    _progressDialog = ProgressDialog(context: context);

    Map<String, dynamic> arguments = ModalRoute
        .of(context)!
        .settings
        .arguments as Map<String, dynamic>;

    cardToken = MercadoPagoCardToken.fromJsonMap(arguments['card_token']);
    identificationType = arguments['identification_type'];
    identificationNumber = arguments['identification_number'];

    print('CARD TOKEN ARGS ${cardToken!.toJson()}');

    _mercadoProvider.init(context, user!);
    getTotalPayment();
    getInstallments();
  }

  void createPay() async {

    if(selectedInstallment == null){
      MySnackbar.show(context!, 'Debes seleccionar el numero de cuotas');
      return;
    }

    Order order = Order(
      idAddress: address!.id,
      idClient: user!.id,
      products: selectedProducts
    );

    _progressDialog!.show(max: 100, msg: 'Realizando transaccion');

    Response? response = await _mercadoProvider.createPayment(
      cardId: cardToken!.cardId != null ? cardToken!.cardId! : '',
      transactionAmount: totalPayment,
      installments: int.parse(selectedInstallment!),
      paymentMethodId: installments!.paymentMethodId!,
      paymentTypeId: installments!.paymentTypeId!,
      issuerId: installments!.issuer!.id!,
      emailCustomer: user!.email!,
      token: cardToken!.id!,
      identificationType: identificationType!,
      identificationNumber: identificationNumber!,
      order: order,
    );

    _progressDialog!.close();

    if(response != null){
      final data = json.decode(response.body);

      if(response.statusCode == 201){
        print('Se genero un pago ${response.body}');
        mercadoPagoPayment = MercadoPagoPayment.fromJsonMap(data);
        print('mercado pago gen ${mercadoPagoPayment!.toJson()}');
      } else if(response.statusCode == 501){
        MySnackbar.show(context!, data['error']['message']);
        if(data != null && data['error']['status'] == 400){
          badRequestProcess(data);
        }
      } else {
        badTokenProcess(data['status'], installments!);
      }
    }

  }

  ///SI SE RECIBE UN STATUS 400
  void badRequestProcess(dynamic data){
    Map<String, String> paymentErrorCodeMap = {
      '3034' : 'Informacion de la tarjeta invalida',
      '205' : 'Ingresa el número de tu tarjeta',
      '208' : 'Digita un mes de expiración',
      '209' : 'Digita un año de expiración',
      '212' : 'Ingresa tu documento',
      '213' : 'Ingresa tu documento',
      '214' : 'Ingresa tu documento',
      '220' : 'Ingresa tu banco emisor',
      '221' : 'Ingresa el nombre y apellido',
      '224' : 'Ingresa el código de seguridad',
      'E301' : 'Hay algo mal en el número. Vuelve a ingresarlo.',
      'E302' : 'Revisa el código de seguridad',
      '316' : 'Ingresa un nombre válido',
      '322' : 'Revisa tu documento',
      '323' : 'Revisa tu documento',
      '324' : 'Revisa tu documento',
      '325' : 'Revisa la fecha',
      '326' : 'Revisa la fecha'
    };
    String? errorMessage;
    print('CODIGO ERROR ${data['error']['cause'][0]['code']}');

    if(paymentErrorCodeMap.containsKey('${data['error']['cause'][0]['code']}')){
      print('ENTRO IF');
      errorMessage = paymentErrorCodeMap['${data['error']['cause'][0]['code']}'];
    }else{
      errorMessage = 'No pudimos procesar tu pago';
    }
    MySnackbar.show(context!, errorMessage!);
    // Navigator.pop(context);
  }

  void badTokenProcess(String status, MercadoPagoPaymentMethodInstallments installments){
    Map<String, String> badTokenErrorCodeMap = {
      '106' : 'No puedes realizar pagos a usuarios de otros paises.',
      '109' : '${installments.paymentMethodId} no procesa pagos en ${selectedInstallment} cuotas',
      '126' : 'No pudimos procesar tu pago.',
      '129' : '${installments.paymentMethodId} no procesa pagos del monto seleccionado.',
      '145' : 'No pudimos procesar tu pago',
      '150' : 'No puedes realizar pagos',
      '151' : 'No puedes realizar pagos',
      '160' : 'No pudimos procesar tu pago',
      '204' : '${installments.paymentMethodId} no está disponible en este momento.',
      '801' : 'Realizaste un pago similar hace instantes. Intenta nuevamente en unos minutos',
    };
    String? errorMessage;
    if(badTokenErrorCodeMap.containsKey(status.toString())){
      errorMessage =  badTokenErrorCodeMap[status];
    }else{
      errorMessage =  'No pudimos procesar tu pago';
    }
    MySnackbar.show(context!, errorMessage!);
    // Navigator.pop(context);
  }

  void getInstallments() async {
    installments = (await _mercadoProvider.getInstallments(
        cardToken!.firstSixDigits!,
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