import 'package:delivery/models/category.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/provider/categories_provider.dart';
import 'package:delivery/utils/my_snackbar.dart';
import 'package:delivery/utils/shared_pref.dart';
import 'package:flutter/material.dart';

class ClientProductsListController {

  BuildContext? context;
  SharedPref _sharedPref = SharedPref();
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  User? user;
  Function? refresh;

  CategoriesProvider _categoriesProvider = new CategoriesProvider();
  late List<Category> categories = [];

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    user = User.fromJson(await _sharedPref.read('user'));
    _categoriesProvider.init(context, sessionUser: user);
    getCategories();
    refresh();
  }

  void getCategories() async {
    categories = await _categoriesProvider.getAll();
    refresh!();
  }

  void logout(){
    _sharedPref.logout(context!, idUser: user!.id);
    MySnackbar.show(context!, 'Se cerró la sesión correctamente');
  }

  void openDrawer(){
    key.currentState!.openDrawer();
  }

  void goToUpdatepage(){
    Navigator.pushNamed(context!, 'client/update');
  }

  void goToRoles(){
    Navigator.pushNamedAndRemoveUntil(context!, 'roles', (route) => false);
  }

}