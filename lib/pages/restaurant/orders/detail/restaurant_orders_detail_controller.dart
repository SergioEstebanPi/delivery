import 'package:delivery/models/order.dart';
import 'package:delivery/models/product.dart';
import 'package:delivery/models/response_api.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/provider/orders_provider.dart';
import 'package:delivery/provider/push_notification_provider.dart';
import 'package:delivery/provider/users_provider.dart';
import 'package:delivery/utils/my_snackbar.dart';
import 'package:delivery/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RestaurantOrdersCreateController {

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
  String? idDelivery;
  OrdersProvider _ordersProvider = OrdersProvider();
  PushNotificationsProvider _pushNotificationsProvider = PushNotificationsProvider();

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

  void sendNotification(String tokenDelivery){
    Map<String, dynamic> data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK'
    };
    _pushNotificationsProvider.sendMessage(
        tokenDelivery,
        data,
        'PEDIDO ASIGNADO',
        'Te han asignado un pedido'
    );
  }

  void updateOrder() async {
    if(idDelivery != null){
      order!.idDelivery = idDelivery;

      ResponseApi responseApi = await _ordersProvider.updateToDispatched(order!);
      //MySnackbar.show(context!, responseApi.message);

      User? deliveryUser = await _usersProvider.getById(order!.idDelivery!);
      print('token de notificacion del delivery: ${deliveryUser!.notificationToken!}');

      if(deliveryUser.notificationToken != null){
        sendNotification(deliveryUser.notificationToken!);
      }

      Fluttertoast.showToast(msg: responseApi.message, toastLength: Toast.LENGTH_LONG);
      Navigator.pop(context!, true);
    } else {
      Fluttertoast.showToast(msg: 'Selecciona el repartidor');
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