import 'package:delivery/models/mercado_pago_credentials.dart';

class Environment {

  static const String API_DELIVERY = "192.168.252.41:3000";
  static const String API_KEY_MAPS = "YOUR KEY HERE";
  static MercadoPagoCredentials mercadoPagoCredentials = MercadoPagoCredentials(
      publicKey: 'YOUR publicKey HERE',
      accessToken: 'YOUR accessToken HERE'
  );

  static const String STRIPE_SECRET = 'YOUR sk KEY HERE';
  static const String STRIPE_PUBLISHABLEKEY = 'YOUR pk KEY HERE';
  static const String FIREBASE_CLOUD_MESSAGING_KEY = 'YOUR firebase cloud messaging key HERE';

}