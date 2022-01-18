import 'dart:io';

import 'package:delivery/models/category.dart';
import 'package:delivery/models/product.dart';
import 'package:delivery/models/response_api.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/provider/categories_provider.dart';
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

  // imagenes
  PickedFile? pickedFile;
  File? imageFile1;
  File? imageFile2;
  File? imageFile3;

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  MoneyMaskedTextController priceController = MoneyMaskedTextController();

  CategoriesProvider _categoriesProvider = CategoriesProvider();

  Future init(BuildContext? context, Function? refresh) async{
    this.context = context;
    this.refresh = refresh;
    user = User.fromJson(await _sharedPref.read('user'));
    _categoriesProvider.init(context, sessionUser: user);
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
      name: name,
      description: description,
      price: price,
      image1: null,
      image2: null,
      image3: null,
      idCategory: int.parse(idCategory!)
    );

    print('Formulario Producto: ${product.toJson()}');

    /*
    _progressDialog!.show(max: 100, msg: 'Cargando...');

    ResponseApi responseApi = await _categoriesProvider.create(product);

    _progressDialog!.close();
    MySnackbar.show(context!, responseApi.message);

    if(responseApi.success){
      nameController.text = '';
      descriptionController.text = '';
    }
     */
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