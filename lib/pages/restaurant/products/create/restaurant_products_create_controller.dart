import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:delivery/models/category.dart';
import 'package:delivery/models/product.dart';
import 'package:delivery/models/response_api.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/provider/categories_provider.dart';
import 'package:delivery/provider/products_provider.dart';
import 'package:delivery/utils/my_snackbar.dart';
import 'package:delivery/utils/shared_pref.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class RestaurantProductsCreateController {
  BuildContext? context;
  Function? refresh;
  ProgressDialog? _progressDialog;
  SharedPref _sharedPref = SharedPref();
  User? user;
  List<Category> categories = [];
  String? idCategory; // id categoria seleccionada
  bool isEnable = true;

  // imagenes
  PickedFile? pickedFile;
  File? imageFile1;
  File? imageFile2;
  File? imageFile3;

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  MoneyMaskedTextController priceController = MoneyMaskedTextController();

  CategoriesProvider _categoriesProvider = CategoriesProvider();
  ProductsProvider _productsProvider = ProductsProvider();

  Future init(BuildContext? context, Function? refresh) async{
    this.context = context;
    this.refresh = refresh;
    user = User.fromJson(await _sharedPref.read('user'));
    _categoriesProvider.init(context, sessionUser: user);
    _productsProvider.init(context, sessionUser: user);
    _progressDialog = ProgressDialog(context: context);
    getCategories();
  }

  void getCategories() async {
    categories = await _categoriesProvider.getAll();
    refresh!();
  }

  void createProduct() async {
    String name = nameController.text;
    String description = descriptionController.text;
    double price = priceController.numberValue;

    if(name.isEmpty || description.isEmpty || price == 0){
      MySnackbar.show(context!, 'Debe ingresar todos los campos');
      return;
    }

    if(imageFile1 == null || imageFile2 == null || imageFile3 == null) {
      MySnackbar.show(context!, 'Selecciona las tres imagenes');
      return;
    }

    if(idCategory == null){
      MySnackbar.show(context!, 'Selecciona la categoria del producto');
      return;
    }

    Product product = Product(
      id_user: user!.id!,
      name: name,
      description: description,
      price: price,
      image1: null,
      image2: null,
      image3: null,
      id_category: int.parse(idCategory!)
    );

    print('Formulario Producto: ${product.toJson()}');

    _progressDialog!.show(max: 100, msg: 'Espere un momento...');
    isEnable = false;

    List<File> images = [];
    images.add(imageFile1!);
    images.add(imageFile2!);
    images.add(imageFile3!);

    Completer<String> completer = Completer();
    String content = "";
    Stream? stream = await _productsProvider.create(product, images);
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
        resetValues();
      }

      isEnable = true;

      print('RESPUESTA: ${responseApi.toJson()}');
    },
    onError: (e) async {
      print('Error');
      completer.completeError(e);
    });

  }

  void resetValues(){
    nameController.text = '';
    descriptionController.text = '';
    priceController.text = '0.0';
    imageFile1 = null;
    imageFile2 = null;
    imageFile3 = null;
    idCategory = null;
    refresh!();
  }

  Future selectImage(ImageSource imageSource, int numberFile) async{
    pickedFile = (await ImagePicker().getImage(source: imageSource))!;
    if(pickedFile != null){
      if(numberFile == 1){
        imageFile1 = File(pickedFile!.path);
      } else if(numberFile == 2){
        imageFile2 = File(pickedFile!.path);
      } else if(numberFile == 3){
        imageFile3 = File(pickedFile!.path);
      }
    }
    Navigator.pop(context!);
    refresh!();
  }

  void showAlertDialog(int numberFile){
    Widget galleryButton = ElevatedButton(
      onPressed: () {
        selectImage(ImageSource.gallery, numberFile);
      },
      child: Text('GALERIA'),
    );
    Widget cameraButton = ElevatedButton(
      onPressed: () {
        selectImage(ImageSource.camera, numberFile);
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

}