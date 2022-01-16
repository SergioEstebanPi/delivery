import 'package:delivery/utils/my_snackbar.dart';
import 'package:flutter/material.dart';

class RestaurantCategoriesCreateController {
  BuildContext? context;
  Function? refresh;

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  Future init(BuildContext? context, Function? refresh) async{
    this.context = context;
    this.refresh = refresh;
  }

  void createCategory(){
    String name = nameController.text;
    String description = descriptionController.text;

    if(name.isEmpty || description.isEmpty){
      MySnackbar.show(context!, 'Debe ingresar todos los campos');
      return;
    }

    print('name: $name');
    print('description: $description');
  }

}