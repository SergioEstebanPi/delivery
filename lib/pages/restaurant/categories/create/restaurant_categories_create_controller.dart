import 'package:delivery/models/category.dart';
import 'package:delivery/models/response_api.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/provider/categories_provider.dart';
import 'package:delivery/utils/my_snackbar.dart';
import 'package:delivery/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class RestaurantCategoriesCreateController {
  BuildContext? context;
  Function? refresh;
  ProgressDialog? _progressDialog;
  SharedPref _sharedPref = SharedPref();
  User? user;

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  CategoriesProvider _categoriesProvider = CategoriesProvider();

  Future init(BuildContext? context, Function? refresh) async{
    this.context = context;
    this.refresh = refresh;
    user = User.fromJson(await _sharedPref.read('user'));
    _categoriesProvider.init(context, sessionUser: user);
    _progressDialog = ProgressDialog(context: context);
  }

  void createCategory() async {
    String name = nameController.text;
    String description = descriptionController.text;

    if(name.isEmpty || description.isEmpty){
      MySnackbar.show(context!, 'Debe ingresar todos los campos');
      return;
    }

    print('name: $name');
    print('description: $description');

    _progressDialog!.show(max: 100, msg: 'Cargando...');

    Category category = Category(
      user_id: user?.id,
      name: name,
      description: description
    );

    ResponseApi responseApi = await _categoriesProvider.create(category);

    _progressDialog!.close();
    MySnackbar.show(context!, responseApi.message);

    if(responseApi.success){
      nameController.text = '';
      descriptionController.text = '';
    }

  }

}