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
  double total = 0;

  Future? init(BuildContext? context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    selectedProducts = Product.fromJsonList(await _sharedPref.read('order') ?? []).toList;
    getTotal();
    refresh();
  }

  void getTotal(){
    total = 0;
    selectedProducts.forEach((product) {
      total = total + (product.price! * product.quantity!);
    });
    refresh!();
  }

  void addItem(Product product){
    int index = selectedProducts.indexWhere((p) => p.id == product.id);
    selectedProducts[index].quantity = selectedProducts[index].quantity! + 1;
    _sharedPref.save('order', selectedProducts);
    getTotal();
  }

  void removeItem(Product product){
    if(product.quantity! > 1){
      int index = selectedProducts.indexWhere((p) => p.id == product.id);
      selectedProducts[index].quantity = selectedProducts[index].quantity! - 1;
      _sharedPref.save('order', selectedProducts);
      getTotal();
    }
  }

  void deleteItem(Product product){
    selectedProducts.removeWhere((p) => p.id == product.id);
    _sharedPref.save('order', selectedProducts);
    getTotal();
  }

  void goToAddress(){
    Navigator.pushNamed(context!, 'client/address/list');
  }

}