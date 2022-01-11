import 'package:delivery/models/user.dart';
import 'package:delivery/utils/shared_pref.dart';
import 'package:flutter/material.dart';

class RolesController {

  BuildContext? context;
  SharedPref _sharedPref = SharedPref();
  User? user;
  Function? refresh;

  Future init(BuildContext? context, Function refresh) async {
    this.context = context;

    // obtener el usuario de sesion puede
    // tardar tiempo es necesario setState para refrescar
    user = User.fromJson(await _sharedPref.read('user') ?? {});
    refresh();
  }

  void goToPage(String route){
    Navigator.pushNamed(context!, route);
  }

}