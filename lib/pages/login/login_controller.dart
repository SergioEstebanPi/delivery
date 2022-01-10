import 'package:delivery/models/response_api.dart';
import 'package:delivery/provider/users_provider.dart';
import 'package:delivery/utils/my_snackbar.dart';
import 'package:flutter/material.dart';

class LoginController {

  // ? null safety
  BuildContext? context;
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  UsersProvider usersProvider = UsersProvider();

  Future init(BuildContext? context) async {
    this.context = context;
    await usersProvider.init(context);
  }

  void goToRegisterPage(){
    Navigator.pushNamed(
        context!,
        'pages.register'
    );
  }

  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    print('email $email');
    print('password $password');

    if(email.isEmpty || password.isEmpty) {
      MySnackbar.show(context!, 'Debe completar los campos');
      return;
    }

    ResponseApi responseApi = await usersProvider.login(email, password);
    print(responseApi);
    MySnackbar.show(context!, responseApi.message);

  }
}