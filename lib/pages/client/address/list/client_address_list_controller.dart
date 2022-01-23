import 'package:delivery/models/address.dart';
import 'package:delivery/models/order.dart';
import 'package:delivery/models/product.dart';
import 'package:delivery/models/response_api.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/provider/address_provider.dart';
import 'package:delivery/provider/orders_provider.dart';
import 'package:delivery/utils/my_snackbar.dart';
import 'package:delivery/utils/shared_pref.dart';
import 'package:flutter/material.dart';

class ClientAddressListController {

  BuildContext? context;
  Function? refresh;
  List<Address> address = [];
  AddressProvider _addressProvider = AddressProvider();
  User? user;
  SharedPref _sharedPref = SharedPref();
  int radioValue = 0;
  OrdersProvider _ordersProvider = OrdersProvider();

  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    user = User.fromJson(await _sharedPref.read('user'));
    _addressProvider.init(context, sessionUser: user);
    _ordersProvider.init(context, sessionUser: user);
    refresh();
  }

  void createOrder() async {
    Address a = Address.fromJson(await _sharedPref.read('address') ?? {});
    List<Product> selectedProducts = Product.fromJsonList(await _sharedPref.read('order') ?? []).toList;

    Order order = Order(
      idClient: user!.id,
      idAddress: a.id,
      products: selectedProducts,
    );
    ResponseApi responseApi = await _ordersProvider.create(order);
    print('Respuesta orden: ${responseApi.toString()}');
    MySnackbar.show(context!, responseApi.message);
    if(responseApi.success){
      MySnackbar.show(context!, 'Se ha creado la orden correctamente');
    }

  }

  void handleRadioValueChange(int? value) async {
    radioValue = value ?? 0;
    _sharedPref.save('address', address[value!]);
    print('Valor radio: $value');

    refresh!();
  }

  Future<List<Address>> getAddress() async {
    address = await _addressProvider.getByUserId(user!.id);

    Address a = Address.fromJson(await _sharedPref.read('address') ?? {});
    print('Se guardo la direccion $a');
    int index = address.indexWhere((ad) => ad.id == a.id);
    if(index != -1){
      radioValue = index;
    }

    return address;
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