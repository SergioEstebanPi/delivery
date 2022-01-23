import 'package:delivery/models/address.dart';
import 'package:delivery/models/response_api.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/pages/client/address/map/client_address_map_page.dart';
import 'package:delivery/provider/address_provider.dart';
import 'package:delivery/utils/my_snackbar.dart';
import 'package:delivery/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ClientAddressCreateController {

  BuildContext? context;
  Function? refresh;
  TextEditingController refPointController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController neighborhoodController = TextEditingController();
  Map<String, dynamic>? refPoint;
  User? user;
  SharedPref _sharedPref = SharedPref();
  AddressProvider _addressProvider = AddressProvider();

  Future? init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    user = User.fromJson(await _sharedPref.read('user'));
    _addressProvider.init(context, sessionUser: user);
    refresh();
  }

  void createAddress() async {
    String addressName = addressController.text;
    String neighborhood = neighborhoodController.text;
    double lat = refPoint != null ? refPoint!['lat'] ?? 0 : 0;
    double lng = refPoint != null ? refPoint!['lng'] ?? 0 : 0;

    if(addressName.isEmpty || neighborhood.isEmpty || lat == 0 || lng == 0){
      MySnackbar.show(context!, 'Completa todos los campos');
      return;
    }

    Address address = Address(
      idUser: user!.id,
      address: addressName,
      neighborhood: neighborhood,
      lat: lat,
      lng: lng
    );

    ResponseApi responseApi = await _addressProvider.create(address);

    if(responseApi.success){
      Fluttertoast.showToast(msg: responseApi.message);
      Navigator.pop(context!);
    }
  }

  void openMap() async {
    refPoint = await showMaterialModalBottomSheet(
        context: context!,
        isDismissible: false,
        enableDrag: false,
        builder: (context) => ClientAddressMapPage()
    );
    if(refPoint != null){
      refPointController.text = refPoint!['address'];
      refresh!();
    }
  }
}