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

class DeliveryOrdersCreateController {

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
    getUsers();
    refresh();
  }

  void updateOrder() async {
    if(order!.status == 'DESPACHADO'){
      ResponseApi responseApi = await _ordersProvider.updateToOnTheWay(order!);
      // al volver atras no se ve el estado de la orden actualizado
      _sharedPref.save('order', order);
      //MySnackbar.show(context!, responseApi.message);
      Fluttertoast.showToast(msg: responseApi.message, toastLength: Toast.LENGTH_LONG);
      if(responseApi.success){
        Fluttertoast.showToast(msg: 'Orden actualizada a DESPACHADO', toastLength: Toast.LENGTH_LONG);
        Navigator.pushNamed(context!, 'delivery/orders/map', arguments: order!.toJson());
        refresh!();
        /*Navigator.pushNamedAndRemoveUntil(
            context!,
            'delivery/orders/map', (route) => false,
            arguments: order!.toJson()
        );*/
      }
    } else {
      Navigator.pushNamed(context!, 'delivery/orders/map', arguments: order!.toJson());
    }
  }

  void getUsers() async {
    users = await _usersProvider.getDeliveryMen();
    refresh!();
  }

  void getTotal(){
    total = 0;
    order!.products.forEach((product) {
      total = total + (product.price! * product.quantity!);
    });
    refresh!();
  }

}