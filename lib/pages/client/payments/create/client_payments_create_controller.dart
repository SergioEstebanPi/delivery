import 'package:delivery/models/mercado_pago_document_type.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/provider/mercado_provider.dart';
import 'package:delivery/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_model.dart';

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

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    cardNumber = creditCardModel.cardNumber;
    expiryDate = creditCardModel.expiryDate;
    cardHolderName = creditCardModel.cardHolderName;
    cvvCode = creditCardModel.cvvCode;
    isCvvFocused = creditCardModel.isCvvFocused;
    refresh!();
  }

}