import 'package:delivery/models/user.dart';
import 'package:flutter/material.dart';

import 'package:delivery/utils/my_snackbar.dart';
import 'package:delivery/utils/shared_pref.dart';
import 'package:flutter/material.dart';

class DeliveryOrdersListController {

  BuildContext? context;
  SharedPref _sharedPref = SharedPref();
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  User? user;
  Function? refresh;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    user = User.fromJson(await _sharedPref.read('user'));
    refresh();
  }

  void logout(){
    _sharedPref.logout(context!);
    MySnackbar.show(context!, 'Se cerró la sesión correctamente');
  }

  void openDrawer(){
    key.currentState!.openDrawer();
  }

  void goToRoles(){
    Navigator.pushNamedAndRemoveUntil(context!, 'roles', (route) => false);
  }

}