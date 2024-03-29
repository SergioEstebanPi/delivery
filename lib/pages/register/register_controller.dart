import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:delivery/models/response_api.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/provider/users_provider.dart';
import 'package:delivery/utils/my_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

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
  PickedFile? pickedFile;
  File? imageFile;
  Function? refresh;
  ProgressDialog? _progressDialog;
  bool isEnable = true;

  Future init(BuildContext? context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    await usersProvider.init(context);
    _progressDialog = ProgressDialog(context: context);
  }

  Future selectImage(ImageSource imageSource) async{
    pickedFile = (await ImagePicker().getImage(source: imageSource))!;
    if(pickedFile != null){
      imageFile = File(pickedFile!.path);
    }
    Navigator.pop(context!);
    refresh!();
  }

  void showAlertDialog(){
    Widget galleryButton = ElevatedButton(
      onPressed: () {
        selectImage(ImageSource.gallery);
      },
      child: Text('GALERIA'),
    );
    Widget cameraButton = ElevatedButton(
      onPressed: () {
        selectImage(ImageSource.camera);
      },
      child: Text('CAMARA'),
    );

    AlertDialog alertDialog = AlertDialog(
      title: Text('Selecciona tu imagen'),
      actions: [
        galleryButton,
        cameraButton
      ],
    );

    showDialog(
      context: context!,
      builder: (BuildContext context){
        return alertDialog;
      }
    );
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

    if(imageFile == null){
      MySnackbar.show(context!, 'Selecciona una imagen');
      return;
    }

    _progressDialog!.show(max: 100, msg: 'Cargando...');
    isEnable = false;

    User user = User(
      email: email,
      name: name,
      lastname: lastName,
      phone: phone,
      password: password
    );

    Completer<String> completer = Completer();
    String content = "";

    Stream? stream = await usersProvider.createWithImage(user, imageFile!);
    stream!.listen((data) {
      content += data;
    },
    onDone: () async {
      _progressDialog!.close();

      completer.complete(content);
      String res = await completer.future;

      //ResponseApi responseApi = await usersProvider.create(user);
      ResponseApi responseApi = ResponseApi.fromJson(json.decode(res));

      print("Respuesta registro: ${responseApi.toJson()}");

      MySnackbar.show(context!, responseApi.message);

      if(responseApi.success){
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pushReplacementNamed(context!, 'login');
        });
      }
      isEnable = true;

      print('RESPUESTA: ${responseApi.toJson()}');
    },
    onError: (e) async {
      print('Error');
      completer.completeError(e);
    });

  }
}