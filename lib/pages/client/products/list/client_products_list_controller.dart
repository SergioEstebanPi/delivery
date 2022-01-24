import 'package:delivery/models/category.dart';
import 'package:delivery/models/product.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/pages/client/products/detail/client_products_detail_page.dart';
import 'package:delivery/provider/categories_provider.dart';
import 'package:delivery/provider/products_provider.dart';
import 'package:delivery/utils/my_snackbar.dart';
import 'package:delivery/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ClientProductsListController {

  BuildContext? context;
  SharedPref _sharedPref = SharedPref();
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  User? user;
  Function? refresh;

  CategoriesProvider _categoriesProvider = new CategoriesProvider();
  late List<Category> categories = [];

  late ProductsProvider _productsProvider = new ProductsProvider();

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    user = User.fromJson(await _sharedPref.read('user'));
    _categoriesProvider.init(context, sessionUser: user);
    _productsProvider.init(context, sessionUser: user);
    getCategories();
    refresh();
  }

  Future<List<Product>> getProducts(String idCategory) async {
    return await _productsProvider.findByCategoryId(idCategory);
  }

  void getCategories() async {
    categories = await _categoriesProvider.getAll();
    refresh!();
  }

  void openBottomSheet(Product product){
    showMaterialModalBottomSheet(
        context: context!,
        builder: (context) => ClientProductsDetailPage(product: product,),
    );
  }

  void logout(){
    _sharedPref.logout(context!, idUser: user!.id);
    MySnackbar.show(context!, 'Se cerró la sesión correctamente');
  }

  void openDrawer(){
    key.currentState!.openDrawer();
  }

  void goToUpdatePage(){
    Navigator.pushNamed(context!, 'client/update');
  }

  void goToRoles(){
    Navigator.pushNamedAndRemoveUntil(context!, 'roles', (route) => false);
  }

  void goToOrdersList(){
    Navigator.pushNamed(context!, 'client/orders/list');
  }

  void goToOrdersCreatePage(){
    Navigator.pushNamed(context!, 'client/orders/create');
  }

}