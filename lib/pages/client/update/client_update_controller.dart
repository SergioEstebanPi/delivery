import 'dart:convert';
import 'dart:io';

import 'package:delivery/models/response_api.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/provider/users_provider.dart';
import 'package:delivery/utils/my_snackbar.dart';
import 'package:delivery/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class ClientUpdateController {

  // ? null safety
  BuildContext? context;
  TextEditingController nameController = new TextEditingController();
  TextEditingController lastNameController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();

  UsersProvider usersProvider = new UsersProvider();
  PickedFile? pickedFile;
  File? imageFile;
  Function? refresh;
  ProgressDialog? _progressDialog;
  bool isEnable = true;
  User? user;
  SharedPref _sharedPref = new SharedPref();

  Future init(BuildContext? context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    await usersProvider.init(context);
    _progressDialog = ProgressDialog(context: context);
    user = User.fromJson(await _sharedPref.read('user'));
    nameController.text = user!.name!;
    lastNameController.text = user!.lastname!;
    phoneController.text = user!.phone!;
    refresh();
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
      title: Text('Selecciona tu image'),
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

    print('name $name');
    print('lastName $lastName');
    print('phone $phone');

    if(name.isEmpty ||
        lastName.isEmpty ||
        phone.isEmpty
    ){
      MySnackbar.show(context!, 'Debes ingresar todos los campos');
      return;
    }

    if(imageFile == null){
      MySnackbar.show(context!, 'Selecciona una imagen');
      return;
    }

    _progressDialog!.show(max: 100, msg: 'Cargando...');
    isEnable = false;

    User user = User(
        name: name,
        lastname: lastName,
        phone: phone,
    );

    Stream? stream = await usersProvider.createWithImage(user, imageFile!);
    stream!.listen((res) {

      _progressDialog!.close();

      //ResponseApi responseApi = await usersProvider.create(user);
      ResponseApi responseApi = ResponseApi.fromJson(json.decode(res));

      print("Respuesta registro: ${responseApi.toJson()}");

      MySnackbar.show(context!, responseApi.message);

      if(responseApi.success){
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pushReplacementNamed(context!, 'login');
        });
      } else {
        isEnable = true;
      }

      print('RESPUESTA: ${responseApi.toJson()}');

    });

  }
}