import 'package:delivery/pages/client/products/list/client_products_list_page.dart';
import 'package:delivery/pages/client/update/client_update_page.dart';
import 'package:delivery/pages/delivery/orders/list/delivery_orders_list_page.dart';
import 'package:delivery/pages/login/login_page.dart';
import 'package:delivery/pages/register/register_page.dart';
import 'package:delivery/pages/restaurant/categories/create/restaurant_categories_create_page.dart';
import 'package:delivery/pages/restaurant/orders/list/restaurant_orders_list_page.dart';
import 'package:delivery/pages/restaurant/products/create/restaurant_products_create_page.dart';
import 'package:delivery/pages/roles/roles_page.dart';
import 'package:delivery/utils/my_colors.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delivery',
      initialRoute: 'login',
      routes: {
        'login': (BuildContext context) => LoginPage(),
        'register': (BuildContext context) => RegisterPage(),
        'client/products/list': (BuildContext context) => ClientProductsListPage(),
        'client/update': (BuildContext context) => ClientUpdatePage(),
        'delivery/orders/list': (BuildContext context) => DeliveryOrdersListPage(),
        'restaurant/orders/list': (BuildContext context) => RestaurantOrdersListPage(),
        'restaurant/categories/create': (BuildContext context) => RestaurantCategoriesCreatePage(),
        'restaurant/products/create': (BuildContext context) => RestaurantProductsCreatePage(),
        'roles': (BuildContext context) => RolesPage(),
      },
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primaryColor: MyColors.primaryColor,
        primarySwatch: Colors.red,
        fontFamily: 'NimbusSans'
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
