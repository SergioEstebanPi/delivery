import 'package:delivery/pages/client/address/create/client_address_create_page.dart';
import 'package:delivery/pages/client/address/list/client_address_list_page.dart';
import 'package:delivery/pages/client/address/map/client_address_map_page.dart';
import 'package:delivery/pages/client/orders/create/client_orders_create_page.dart';
import 'package:delivery/pages/client/orders/list/client_orders_list_page.dart';
import 'package:delivery/pages/client/orders/map/client_orders_map_page.dart';
import 'package:delivery/pages/client/payments/create/client_payments_create_page.dart';
import 'package:delivery/pages/client/payments/installments/client_payments_installments_page.dart';
import 'package:delivery/pages/client/payments/status/client_payments_status_page.dart';
import 'package:delivery/pages/client/products/list/client_products_list_page.dart';
import 'package:delivery/pages/client/update/client_update_page.dart';
import 'package:delivery/pages/delivery/orders/list/delivery_orders_list_page.dart';
import 'package:delivery/pages/delivery/orders/map/delivery_orders_map_page.dart';
import 'package:delivery/pages/login/login_page.dart';
import 'package:delivery/pages/register/register_page.dart';
import 'package:delivery/pages/restaurant/categories/create/restaurant_categories_create_page.dart';
import 'package:delivery/pages/restaurant/orders/list/restaurant_orders_list_page.dart';
import 'package:delivery/pages/restaurant/products/create/restaurant_products_create_page.dart';
import 'package:delivery/pages/roles/roles_page.dart';
import 'package:delivery/provider/push_notification_provider.dart';
import 'package:delivery/utils/my_colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

PushNotificationsProvider pushNotificationsProvider = PushNotificationsProvider();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage((message) => _firebaseMessagingBackgroundHandler(message));
  pushNotificationsProvider.initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //  inicia a escuchar los cambios de notificaciones
    pushNotificationsProvider.onMessageListener();
  }

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
        'client/orders/create': (BuildContext context) => ClientOrdersCreatePage(),
        'client/address/list': (BuildContext context) => ClientAddressListPage(),
        'client/address/create': (BuildContext context) => ClientAddressCreatePage(),
        'client/address/map': (BuildContext context) => ClientAddressMapPage(),
        'client/orders/list': (BuildContext context) => ClientOrdersListPage(),
        'client/orders/map': (BuildContext context) => ClientOrdersMapPage(),
        'client/payments/create': (BuildContext context) => ClientPaymentsCreatePage(),
        'client/payments/installments': (BuildContext context) => ClientPaymentsInstallmentsPage(),
        'client/payments/status': (BuildContext context) => ClientPaymentsStatusPage(),
        'delivery/orders/list': (BuildContext context) => DeliveryOrdersListPage(),
        'delivery/orders/map': (BuildContext context) => DeliveryOrdersMapPage(),
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
        fontFamily: 'NimbusSans',
        appBarTheme: AppBarTheme(
          elevation: 0
        )
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
