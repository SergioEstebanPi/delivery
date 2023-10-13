import 'dart:convert';

import 'package:delivery/models/mercado_pago_card_token.dart';
import 'package:delivery/models/mercado_pago_document_type.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/provider/epayco_provider.dart';
import 'package:delivery/provider/mercado_provider.dart';
import 'package:delivery/utils/my_snackbar.dart';
import 'package:delivery/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../models/address.dart';
import '../../../../models/order.dart';
import '../../../../models/product.dart';

class ClientPaymentsCreateController {

  BuildContext? context;
  Function? refresh;
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  GlobalKey<FormState> keyForm = GlobalKey();
  List<MercadoPagoDocumentType>? documentTypeList = [];
  MercadoProvider _mercadoProvider = MercadoProvider();
  EpaycoProvider _epaycoProvider = EpaycoProvider();
  User? user;
  SharedPref _sharedPref = SharedPref();
  String typeDocument = 'CC';
  TextEditingController documentNumberController = TextEditingController();
  String expirationYear = '';
  int expirationMonth = 1;
  MercadoPagoCardToken? mercadoPagoCardToken;
  List<Product> selectedProducts = [];
  double totalPayment = 0;
  Address? address;

  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    user = User.fromJson(await _sharedPref.read('user'));
    address = Address.fromJson(await _sharedPref.read('address'));

    selectedProducts = Product.fromJsonList(await _sharedPref.read('order') ?? []).toList;

    _mercadoProvider.init(context, user!);
    _epaycoProvider.init(context, user!);
    getIdentificationTypes();
  }

  void getIdentificationTypes() async {
    documentTypeList = await _mercadoProvider.getIdentificationTypes();

    if(documentTypeList != null){
      documentTypeList!.forEach((element) {
        print('DocumentType: $element');
      });
    }
    refresh!();
  }

  Future<void> createCardToken() async {
    String documentNumber = documentNumberController.text;
    if (documentNumberController == '') {
      MySnackbar.show(context!, "Ingresa el numero de documento");
      return;
    }
    if (cardNumber.isEmpty) {
      MySnackbar.show(context!, "Ingresa el numero de la tarjeta");
    }
    if (expiryDate.isEmpty) {
      MySnackbar.show(context!, "Ingresa la fecha de expiracion");
      return;
    }
    if (cvvCode.isEmpty) {
      MySnackbar.show(context!, "Ingresa el codigo de seguridad de la tarjeta");
      return;
    }
    if (cardHolderName.isEmpty) {
      MySnackbar.show(context!, "Ingresa el titular de la tarjeta");
      return;
    }

    if (expiryDate != null) {
      List<String> list = expiryDate.split('/');
      if (list.length == 2) {
        expirationMonth = int.parse(list[0]);
        expirationYear = '20${list[1]}';
      } else {
        MySnackbar.show(
            context!, 'Inserta el mes y el año de expiracion de la tarjeta');
      }
    }

    if (cardNumber != null) {
      cardNumber = cardNumber.replaceAll(RegExp(' '), '');
    }

    print('CVV: $cvvCode');
    print('Card Number: $cardNumber');
    print('cardHolderName: $cardHolderName');
    print('documentId: $typeDocument');
    print('documentNumber: $documentNumber');
    print('expirationMonth: $expirationMonth');
    print('expirationYear: $expirationYear');

    // print('CARD TOKEN ARGS ${cardToken!.toJson()}');
    print('CARD TOKEN selectedProducts $selectedProducts');

    //_mercadoProvider.init(context, user!);
    for (var p in selectedProducts) {
      totalPayment = totalPayment + (p.quantity! * p.price!);
    }
    print('totalPayment $totalPayment');

    Order order = Order(
        idAddress: address!.id,
        idClient: user!.id,
        products: selectedProducts
    );

    Response? response = await _epaycoProvider.createPayment(
      cardNumber: cardNumber,
      expYear: expirationYear,
      expMonth: expirationMonth.toString(),
      cvc: cvvCode,
      documentNumber: documentNumber,
      documentId: typeDocument,
      cardHolderName: cardHolderName,
      order: order
    );

    print('DATOS PAGO EPAYCO: ${response}');
    if(response != null){
      print('Se genero un pago Epayco ${response.body}');
      //mercadoPagoPayment = MercadoPagoPayment.fromJsonMap(data);
      //print('mercado pago gen ${mercadoPagoPayment!.toJson()}');
      final data = json.decode(response.body);

      if(data['status'] == "true" && data['success'] == "true"){

        Navigator.pushNamedAndRemoveUntil(
            context!,
            'epayco/payments/status',
                (route) => false,
            arguments: {
              'status': "true",
              'success': "true",
              'brand': data['brand'],
              'last4': data['last4']
            }
        );
        /*
        Navigator.pushNamedAndRemoveUntil(
            context!,
            'client/payments/status',
                (route) => false,
            arguments: {'brand': 'mastercard', 'last4': '123'}
        );

         */
      } else {
        print('Error al procesar pago Epayco ${response}');
        Navigator.pushNamedAndRemoveUntil(
            context!,
            'epayco/payments/status',
                (route) => false,
            arguments: {'brand': data['brand'], 'last4': data['last4']}
        );
      }

    } else {
        print('Error al procesar pago Epayco ${response}');
    }
    /*
    Response? response = await _mercadoProvider.createCardToken(
        cvv: cvvCode,
        expirationYear: expirationYear,
        expirationMonth: expirationMonth,
        cardNumber: cardNumber,
        documentNumber: documentNumber,
        documentId: typeDocument,
        cardHolderName: cardHolderName
    );

    if(response != null){
      final data = json.decode(response.body);
      if(response.statusCode == 201) {
        mercadoPagoCardToken = MercadoPagoCardToken.fromJsonMap(data);
        print('CARD TOKEN: ${mercadoPagoCardToken!.toJson()}');
        
        Navigator.pushNamed(
            context!,
            'client/payments/installments',
            arguments: {
              'identification_type': typeDocument,
              'identification_number': documentNumber,
              'card_token': mercadoPagoCardToken!.toJson()
            }
        );
        
      } else {
        print('Hubo error generando el token de la tarjeta');
        int? status = int.tryParse(data['cause'][0]['code'] ?? data['status']);
        String message = data['message'] ?? 'Error al registrar la tarjeta';
        MySnackbar.show(context!, 'Mercado pago status code $status - $message');
      }
    }
    */

  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    cardNumber = creditCardModel.cardNumber;
    expiryDate = creditCardModel.expiryDate;
    cardHolderName = creditCardModel.cardHolderName;
    cvvCode = creditCardModel.cvvCode;
    isCvvFocused = creditCardModel.isCvvFocused;

    refresh!();
  }

}