import 'package:delivery/models/address.dart';
import 'package:delivery/models/order.dart';
import 'package:delivery/models/product.dart';
import 'package:delivery/models/response_api.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/provider/address_provider.dart';
import 'package:delivery/provider/orders_provider.dart';
import 'package:delivery/provider/stripe_provider.dart';
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
  ProgressDialog? _progressDialog;

  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    _progressDialog = ProgressDialog(context: context);
    user = User.fromJson(await _sharedPref.read('user'));
    _addressProvider.init(context, sessionUser: user);
    _ordersProvider.init(context, sessionUser: user);
    _stripeProvider.init(context);
    getAddress();
    refresh();
  }

  void createOrder() async {

    _progressDialog!.show(max: 100, msg: 'Espere un momento');
    var response = await _stripeProvider.payWithCard('${150 * 100}', 'USD');
    _progressDialog!.close();

    MySnackbar.show(context!, response!.message);

    if(response != null && response.success){
      Address address = Address.fromJson(await _sharedPref.read('address'));
      List<Product> selectedProducts = Product.fromJsonList(await _sharedPref.read('order') ?? []).toList;

      Order order = Order(
        idClient: user!.id,
        idAddress: address.id,
        products: selectedProducts,
      );
      ResponseApi responseApi = await _ordersProvider.create(order);

      print('Respuesta orden: ${responseApi.toString()}');
      if(responseApi.success) {

        Navigator.pushNamedAndRemoveUntil(
            context!,
            'client/payments/status',
            (route) => false,
          arguments: {
              'brand': response.paymentMethod.card!.brand,
              'last4': response.paymentMethod.card!.last4
          }
        );
      }



      //Navigator.pushNamed(context!, 'client/payments/create');

      /*
    print('Respuesta orden: ${responseApi.toString()}');
    MySnackbar.show(context!, responseApi.message);
    if(responseApi.success){
      MySnackbar.show(context!, 'Se ha creado la orden correctamente');
    }
     */
    }

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