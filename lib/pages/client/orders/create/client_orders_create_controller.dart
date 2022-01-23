import 'package:delivery/models/product.dart';
import 'package:delivery/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ClientProductsCreateController {

  BuildContext? context;
  Function? refresh;
  int counter = 1;
  double? productPrice;
  SharedPref _sharedPref = SharedPref();
  List<Product> selectedProducts = [];

  Future? init(BuildContext? context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    selectedProducts = Product.fromJsonList(await _sharedPref.read('order') ?? []).toList;
    refresh();
  }

}