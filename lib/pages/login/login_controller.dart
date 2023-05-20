import 'package:delivery/models/response_api.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/provider/push_notification_provider.dart';
import 'package:delivery/provider/users_provider.dart';
import 'package:delivery/utils/my_snackbar.dart';
import 'package:delivery/utils/shared_pref.dart';
import 'package:flutter/material.dart';

class LoginController {

  // ? null safety
  BuildContext? context;
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  UsersProvider usersProvider = UsersProvider();
  SharedPref _sharedPref = SharedPref();

  PushNotificationsProvider pushNotificationsProvider = PushNotificationsProvider();

  Future init(BuildContext? context) async {
    this.context = context;
    await usersProvider.init(context);

    User user = User.fromJson(await _sharedPref.read('user') ?? {});
    print('Usuario ${user.toJson()}');
    if(user != null && user.id != null && user.sessionToken != null){

      pushNotificationsProvider.saveToken(user, context!);

      if(user.roles != null){
        if(user.roles!.length > 1) {
          Navigator.pushNamedAndRemoveUntil(context, 'roles', (route) => false);
        } else {
          String? route = user.roles![0].route;
          Navigator.pushNamedAndRemoveUntil(context, route!, (route) => false);
        }
      }
    }
  }

  void goToRegisterPage(){
    Navigator.pushNamed(
        context!,
        'register'
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
    print('Respuesta object: ${responseApi}');
    print('Respuesta: ${responseApi.toJson()}');

    if(responseApi.success){
      User user = User.fromJson(responseApi.data);
      _sharedPref.save('user', user.toJson());

      pushNotificationsProvider.saveToken(user, context!);

      print('Usuario logeado ${user.toJson()}');
      if(user.roles != null){
        if(user.roles!.length > 1) {
          Navigator.pushNamedAndRemoveUntil(context!, 'roles', (route) => false);
        } else {
          String? route = user.roles![0].route;
          Navigator.pushNamedAndRemoveUntil(context!, route!, (route) => false);
        }
      }
    } else {
      MySnackbar.show(context!, 'Error de conexión con el servidor');
    }
  }

}