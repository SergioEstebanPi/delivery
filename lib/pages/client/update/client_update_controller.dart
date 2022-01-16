import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:delivery/models/response_api.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/provider/users_provider.dart';
import 'package:delivery/utils/my_snackbar.dart';
import 'package:delivery/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  SharedPref _sharedPref = SharedPref();

  Future init(BuildContext? context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _progressDialog = ProgressDialog(context: context);
    user = User.fromJson(await _sharedPref.read('user'));
    print('Formulario editar usuario: ${user.toString()}');
    await usersProvider.init(context, token: user!.sessionToken);
    nameController.text = user!.name!;
    lastNameController.text = user!.lastname!;
    phoneController.text = user!.phone!;
    //imageFile = File(user!.image!);
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

  void update() async {
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

    _progressDialog!.show(max: 100, msg: 'Cargando...');
    isEnable = false;

    User myUser = User(
        id: user!.id,
        name: name,
        lastname: lastName,
        phone: phone,
        image: user!.image
    );

    Completer<String> completer = Completer();
    String content = "";

    Stream? stream = await usersProvider.update(myUser, imageFile);
    stream!.listen((data) async {
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
        user = await usersProvider.getById(myUser.id!); //obtiene el usuario de la base de datos
        print('Usuario obtenido: ${user!.toJson()}');
        _sharedPref.save('user', user!.toJson());
        Navigator.pushNamedAndRemoveUntil(context!, 'client/products/list', (route) => false);
      } else {
        isEnable = true;
      }

      print('RESPUESTA: ${responseApi.toJson()}');

    },
    onError: (e) {
      print('Error');
      completer.completeError(e);
    });

  }
}