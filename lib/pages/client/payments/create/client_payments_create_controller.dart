import 'dart:convert';

import 'package:delivery/models/mercado_pago_card_token.dart';
import 'package:delivery/models/mercado_pago_document_type.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/provider/mercado_provider.dart';
import 'package:delivery/utils/my_snackbar.dart';
import 'package:delivery/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:http/http.dart';

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
  User? user;
  SharedPref _sharedPref = SharedPref();
  String typeDocument = 'CC';
  TextEditingController documentNumberController = TextEditingController();
  String expirationYear = '';
  int expirationMonth = 1;
  MercadoPagoCardToken? mercadoPagoCardToken;

  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    user = User.fromJson(await _sharedPref.read('user'));

    _mercadoProvider.init(context, user!);
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
    if(documentNumberController == ''){
      MySnackbar.show(context!, "Ingresa el numero de documento");
      return;
    }
    if(cardNumber.isEmpty){
      MySnackbar.show(context!, "Ingresa el numero de la tarjeta");
    }
    if(expiryDate.isEmpty){
      MySnackbar.show(context!, "Ingresa la fecha de expiracion");
      return;
    }
    if(cvvCode.isEmpty){
      MySnackbar.show(context!, "Ingresa el codigo de seguridad de la tarjeta");
      return;
    }
    if(cardHolderName.isEmpty){
      MySnackbar.show(context!, "Ingresa el titular de la tarjeta");
      return;
    }

    if(expiryDate != null){
      List<String> list = expiryDate.split('/');
      if(list.length == 2){
        expirationMonth = int.parse(list[0]);
        expirationYear = '20${list[1]}';
      } else {
        MySnackbar.show(context!, 'Inserta el mes y el año de expiracion de la tarjeta');
      }
    }

    if(cardNumber != null) {
      cardNumber = cardNumber.replaceAll(RegExp(' '), '');
    }

    print('CVV: $cvvCode');
    print('Card Number: $cardNumber');
    print('cardHolderName: $cardHolderName');
    print('documentId: $typeDocument');
    print('documentNumber: $documentNumber');
    print('expirationMonth: $expirationMonth');
    print('expirationYear: $expirationYear');
    
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
            arguments: mercadoPagoCardToken!.toJson()
        );
        
      } else {
        print('Hubo error generando el token de la tarjeta');
        int? status = int.tryParse(data['cause'][0]['code'] ?? data['status']);
        String message = data['message'] ?? 'Error al registrar la tarjeta';
        MySnackbar.show(context!, 'Mercado pago status code $status - $message');
      }
    }

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