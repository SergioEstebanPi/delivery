import 'package:delivery/models/order.dart';
import 'package:delivery/models/product.dart';
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

  Future? init(BuildContext? context, Function refresh, Order order) async {
    this.context = context;
    this.refresh = refresh;
    this.order = order;
    getTotal();
    refresh();
  }

  void getTotal(){
    total = 0;
    order!.products.forEach((product) {
      total = total + (product.price! * product.quantity!);
    });
    refresh!();
  }

}