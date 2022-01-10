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

  Future init(BuildContext? context) async {
    this.context = context;
  }

  void goToLoginPage(){
    Navigator.pushNamed(
        context!,
        'login'
    );
  }

  void register(){
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
  }
}