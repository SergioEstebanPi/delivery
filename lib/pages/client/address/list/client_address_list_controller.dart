import 'package:delivery/models/address.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/provider/address_provider.dart';
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

  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    user = User.fromJson(await _sharedPref.read('user'));
    _addressProvider.init(context, sessionUser: user);
    refresh();
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