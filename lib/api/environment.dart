import 'package:delivery/models/mercado_pago_credentials.dart';

class Environment {

  static const String API_DELIVERY = "192.168.252.41:3000";
  static const String API_KEY_MAPS = "YOUR KEY HERE";
  static MercadoPagoCredentials mercadoPagoCredentials = MercadoPagoCredentials(
      publicKey: 'YOUR publicKey HERE',
      accessToken: 'YOUR accessToken HERE'
  );

}