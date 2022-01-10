import 'package:delivery/models/response_api.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/provider/users_provider.dart';
import 'package:delivery/utils/my_snackbar.dart';
import 'package:flutter/material.dart';

class RegisterController {

  // ? null safety
  BuildContext? context;
  TextEditingController nameController = new TextEditingController();
  TextEditingController lastNameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();

  UsersProvider usersProvider = new UsersProvider();

  Future init(BuildContext? context) async {
    this.context = context;
    await usersProvider.init(context);
  }

  void back(){
    Navigator.pop(context!);
  }

  void register() async {
    String name = nameController.text;
    String lastName = lastNameController.text;
    String phone = phoneController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    print('name $name');
    print('lastName $lastName');
    print('email $email');
    print('phone $phone');
    print('password $password');
    print('confirmPassword $confirmPassword');

    if(email.isEmpty ||
        name.isEmpty ||
        lastName.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty
    ){
      MySnackbar.show(context!, 'Debes ingresar todos los campos');
      return;
    }

    if(password.length < 6){
      MySnackbar.show(context!, 'La contraseña debe tener mas de 6 caracteres');
      return;
    }

    if(confirmPassword != password){
      MySnackbar.show(context!, 'Las contraseñas no coinciden');
      return;
    }

    User user = User(
      email: email,
      name: name,
      lastname: lastName,
      phone: phone,
      password: password
    );

    ResponseApi responseApi = await usersProvider.create(user);
    print("Respuesta registro: ${responseApi.toJson()}");

    MySnackbar.show(context!, responseApi.message);

  }
}