import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:delivery/models/address.dart';
import 'package:delivery/models/order.dart';
import 'package:delivery/models/product.dart';
import 'package:delivery/models/response_api.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/provider/address_provider.dart';
import 'package:delivery/provider/orders_provider.dart';
import 'package:delivery/provider/push_notification_provider.dart';
import 'package:delivery/provider/stripe_provider.dart';
import 'package:delivery/provider/users_provider.dart';
import 'package:delivery/utils/my_snackbar.dart';
import 'package:delivery/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class ClientAddressListController {

  BuildContext? context;
  Function? refresh;
  List<Address> addresses = [];
  AddressProvider _addressProvider = AddressProvider();
  User? user;
  SharedPref _sharedPref = SharedPref();
  int radioValue = 0;
  OrdersProvider _ordersProvider = OrdersProvider();
  StripeProvider _stripeProvider = StripeProvider();
  UsersProvider _usersProvider = UsersProvider();
  PushNotificationsProvider _pushNotificationsProvider = PushNotificationsProvider();
  ProgressDialog? _progressDialog;

  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _progressDialog = ProgressDialog(context: context);
    user = User.fromJson(await _sharedPref.read('user'));
    _addressProvider.init(context, sessionUser: user);
    _ordersProvider.init(context, sessionUser: user);
    _usersProvider.init(context, sessionUser: user);
    //_stripeProvider.init(context);
    getAddress();
    refresh();
  }

  void createOrder() async {

    _progressDialog!.show(max: 100, msg: 'Espera un momento');
    //var response = await _stripeProvider.payWithCard('${150 * 100}', 'USD');
    _progressDialog!.close();

    //MySnackbar.show(context!, response!.message);

    //if(response != null && response.success){
      Address address = Address.fromJson(await _sharedPref.read('address'));
      List<Product> selectedProducts = Product.fromJsonList(await _sharedPref.read('order') ?? []).toList;

    print('selectedProducts: ' + selectedProducts.toString());
    MySnackbar.show(context!, 'selectedProducts: ' + selectedProducts.toString());

    for(var product in selectedProducts){
      print('Productos de la orden: ');
      print(product.toJson());
      MySnackbar.show(context!, 'Productos de la orden: ' + product.toString());
      MySnackbar.show(context!, product.toJson().toString());
    }

    Map<String?, List<Product>> grupos = groupProductsByRestaurant(selectedProducts);

    if(grupos.length > 1) {
      print('Se crearán varias ordenes');
      MySnackbar.show(context!, 'Se crearán varias ordenes');
    } else {
      print('Se creará 1 orden');
      MySnackbar.show(context!, 'Se creará 1 orden');
    }

    Navigator.pushNamed(context!, 'client/payments/create');

    /*
    grupos.forEach((idUser, productsIdUser) async {
      Order order = Order(
        idUser: idUser,
        idClient: user!.id,
        idAddress: address.id,
        products: productsIdUser,
      );

      ResponseApi responseApi = await _ordersProvider.create(order);

      print('Respuesta orden: ${responseApi.toString()}');
      print(responseApi);
      if(responseApi.success) {
        MySnackbar.show(context!, responseApi.message);
        if(responseApi.success){
          MySnackbar.show(context!, 'Se ha creado la orden correctamente');
          await _sharedPref.remove('order');
          refresh!();
          // notificar a restaurantes por cada producto

          User? restaurantUser = await _usersProvider.getById(idUser!);
          print('token de notificacion de restaurante: ${restaurantUser!.notificationToken!}');

          if(restaurantUser.notificationToken != null){
            sendNotification(restaurantUser.notificationToken!);
          }
        }
      } else {
        MySnackbar.show(context!, 'ERROR AL CREAR LA ORDEN');
        MySnackbar.show(context!, 'ERROR AL CREAR LA ORDEN MSG ' + responseApi.message);
        if(responseApi.error) {
          print('ERROR AL CREAR LA ORDEN ' + responseApi.error);
        }
        print('ERROR AL CREAR LA ORDEN MSG ' + responseApi.message);
      }
    });

     */



      //Navigator.pushNamed(context!, 'client/payments/create'); // mercadopago

        /*
        Navigator.pushNamedAndRemoveUntil(
            context!,
            'client/payments/status',
            (route) => false,
          arguments: {
              'brand': response.paymentMethod.card!.brand,
              'last4': response.paymentMethod.card!.last4
          }
        );
         */
     // }



      //Navigator.pushNamed(context!, 'client/payments/create');

      /*
    print('Respuesta orden: ${responseApi.toString()}');
    MySnackbar.show(context!, responseApi.message);
    if(responseApi.success){
      MySnackbar.show(context!, 'Se ha creado la orden correctamente');
    }
     */

  }

  Map<String?, List<Product>> groupProductsByRestaurant(List<Product> products) {
    final groups = groupBy(products, (Product p) {
      return p.id_user;
    });

    print("Grupos de restaurantes de la orden: ");
    print(groups);
    return groups;
  }

  void sendNotification(String tokenDelivery){
    Map<String, dynamic> data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK'
    };
    _pushNotificationsProvider.sendMessage(
        tokenDelivery,
        data,
        'NUEVO PEDIDO CREADO',
        'Tienes una nueva orden pendiente'
    );
  }

  void handleRadioValueChange(int? value) async {
    radioValue = value ?? 0;
    _sharedPref.save('address', addresses[value!]);
    print('Valor radio: $value');

    refresh!();
  }

  Future<List<Address>> getAddress() async {
    addresses = await _addressProvider.getByUserId(user!.id);

    Address a = Address.fromJson(await _sharedPref.read('address') ?? {});
    print('Se guardo la direccion ${a.toJson()}');
    int index = addresses.indexWhere((ad) => ad.id == a.id);
    if(index != -1){
      radioValue = index;
    }

    return addresses;
  }

  void goToNewAddress() async {
    var result = await Navigator.pushNamed(context!, 'client/address/create');
    if(result != null){
      if(result == true){
        refresh!();
      }
    }
  }
}