import 'package:flutter/material.dart';

class LoginController {

  // ? null safety
  BuildContext? context;
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  Future init(BuildContext? context) async {
    this.context = context;
  }

  void goToRegisterPage(){
    Navigator.pushNamed(
        context!,
        'pages.register'
    );
  }

  void login(){
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    print('email $email');
    print('password $password');
  }
}