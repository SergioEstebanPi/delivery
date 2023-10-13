import 'dart:convert';

import 'package:delivery/models/address.dart';
import 'package:delivery/models/epayco_payment.dart';
import 'package:delivery/models/order.dart';
import 'package:delivery/models/product.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/provider/push_notification_provider.dart';
import 'package:delivery/provider/users_provider.dart';
import 'package:delivery/utils/my_snackbar.dart';
import 'package:delivery/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:http/http.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class EpaycoPaymentsStatusController {

  BuildContext? context;
  Function? refresh;
  //EpaycoPayment? epaycoPayment;
  String errorMessage = '';
  String status = '';
  String success = '';
  String brandCard = '';
  String last4 = '';

  PushNotificationsProvider _pushNotificationsProvider = PushNotificationsProvider();
  UsersProvider _usersProvider = UsersProvider();
  List<String> tokens = [];
  User? user;
  SharedPref _sharedPref = SharedPref();

  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    Map<String, dynamic> arguments = ModalRoute
        .of(context)!
        .settings
        .arguments as Map<String, dynamic>;

    print(arguments);

    status = arguments['status'] ?? '';
    success = arguments['success'] ?? '';
    brandCard = arguments['brand'] ?? '';
    last4 = arguments['last4'] ?? '';

    user = User.fromJson(await _sharedPref.read('user'));

    if(status == '' || status == 'false') {
      createErrorMessage();
    } else {
      _usersProvider.init(context, sessionUser: user);
      tokens = await _usersProvider.getAdminsNotificationsTokens();
      sendNotification();
    }

    refresh();
  }

  void sendNotification(){

    List<String> registration_ids = [];

    tokens.forEach((token) {
      if(token != null){
        registration_ids.add(token);
      }
    });

    Map<String, dynamic> data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK'
    };
    _pushNotificationsProvider.sendMessageMultiple(
        registration_ids,
        data,
        'COMPRA EXITOSA',
        'Un cliente ha realizado un pedido'
    );
  }

  void finishShopping(){
    Navigator.pushNamedAndRemoveUntil(context!, 'client/products/list', (route) => false);
  }

  void createErrorMessage() {
    errorMessage = 'Revisa el número de tarjeta';
  }

}