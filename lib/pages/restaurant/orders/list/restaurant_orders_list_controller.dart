import 'package:delivery/models/order.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/provider/orders_provider.dart';
import 'package:flutter/material.dart';

import 'package:delivery/utils/my_snackbar.dart';
import 'package:delivery/utils/shared_pref.dart';
import 'package:flutter/material.dart';

class RestaurantOrdersListController {

  BuildContext? context;
  SharedPref _sharedPref = SharedPref();
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  User? user;
  Function? refresh;
  List<String> categories = [
    'PAGADO',
    'DESPACHADO',
    'EN CAMINO',
    'ENTREGADO'
  ];
  OrdersProvider _ordersProvider = OrdersProvider();

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    user = User.fromJson(await _sharedPref.read('user'));
    _ordersProvider.init(context, sessionUser: user);
    refresh();
  }

  Future<List<Order>> getOrders(String status) async {
    return await _ordersProvider.getByStatus(status);
  }

  void logout(){
    _sharedPref.logout(context!, idUser: user!.id);
    MySnackbar.show(context!, 'Se cerró la sesión correctamente');
  }

  void goToCategoryCreate(){
    Navigator.pushNamed(context!, 'restaurant/categories/create');
  }

  void goToProductCreate(){
    Navigator.pushNamed(context!, 'restaurant/products/create');
  }

  void openDrawer(){
    key.currentState!.openDrawer();
  }

  void goToRoles(){
    Navigator.pushNamedAndRemoveUntil(context!, 'roles', (route) => false);
  }

}