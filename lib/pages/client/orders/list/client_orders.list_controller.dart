import 'package:delivery/models/order.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/pages/client/orders/detail/client_orders_detail_page.dart';
import 'package:delivery/pages/delivery/orders/detail/delivery_orders_detail_page.dart';
import 'package:delivery/pages/restaurant/orders/detail/restaurant_orders_detail_page.dart';
import 'package:delivery/provider/orders_provider.dart';
import 'package:flutter/material.dart';

import 'package:delivery/utils/my_snackbar.dart';
import 'package:delivery/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ClientOrdersListController {

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

  Future<List<Order>?> getOrders(String status) async {
    if(user != null){
      return await _ordersProvider.getByClientAndStatus(user!.id!, status);
    }
    return [];
  }

  void openBottomSheet(Order order) async {
    var isUpdated = await showMaterialModalBottomSheet(
        context: context!,
        builder: (context) => ClientOrdersDetailPage(
            order: order
        )
    );
    if(isUpdated != null && isUpdated){
      refresh!();
    }
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