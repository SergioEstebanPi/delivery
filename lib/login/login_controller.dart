import 'package:flutter/material.dart';

class LoginController {

  // ? null safety
  BuildContext? context;

  Future init(BuildContext? context) async {
    this.context = context;
  }

  void goToRegisterPage(){
    Navigator.pushNamed(
        context!,
        'register'
    );
  }
}