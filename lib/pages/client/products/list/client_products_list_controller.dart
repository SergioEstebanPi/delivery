import 'package:delivery/utils/my_snackbar.dart';
import 'package:delivery/utils/shared_pref.dart';
import 'package:flutter/material.dart';

class ClientProductsListController {

  BuildContext? context;
  SharedPref _sharedPref = SharedPref();

  Future init(BuildContext context) async {
    this.context = context;
  }

  logout(){
    _sharedPref.logout(context!);
    MySnackbar.show(context!, 'Se cerró la sesión correctamente');
  }

}