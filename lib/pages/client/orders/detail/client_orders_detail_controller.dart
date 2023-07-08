import 'package:delivery/models/order.dart';
import 'package:delivery/models/product.dart';
import 'package:delivery/models/response_api.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/provider/orders_provider.dart';
import 'package:delivery/provider/users_provider.dart';
import 'package:delivery/utils/my_snackbar.dart';
import 'package:delivery/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ClientOrdersCreateController {

  BuildContext? context;
  Function? refresh;
  int counter = 1;
  double? productPrice;
  SharedPref _sharedPref = SharedPref();
  double total = 0;
  Order? order;
  User? user;
  List<User> users = [];
  UsersProvider _usersProvider = UsersProvider();
  OrdersProvider _ordersProvider = OrdersProvider();

  Future? init(BuildContext? context, Function refresh, Order order) async {
    this.context = context;
    this.refresh = refresh;
    this.order = order;
    user = User.fromJson(await _sharedPref.read('user'));
    _usersProvider.init(context, sessionUser: user);
    _ordersProvider.init(context, sessionUser: user);
    getTotal();
    refresh();
  }

  void showMap() {
    Navigator.pushNamed(context!, 'client/orders/map', arguments: order!.toJson());
  }

  void getTotal(){
    total = 0;
    order!.products.forEach((product) {
      total = total + (product.price! * product.quantity!);
    });
    refresh!();
  }

  confirmCancelation(Order? order) async {
    ResponseApi responseApi = await _ordersProvider.updateToCanceled(order!);
    if(responseApi.success){
      Fluttertoast.showToast(msg: 'Pedido cancelado exitosamente', toastLength: Toast.LENGTH_LONG);
      refresh!();
      Navigator.pushNamedAndRemoveUntil(
          context!,
          'client/orders/list',
              (route) => false
      );
    } else {
      Fluttertoast.showToast(msg: 'Error al cancelar el pedido', toastLength: Toast.LENGTH_LONG);
    }
  }

}