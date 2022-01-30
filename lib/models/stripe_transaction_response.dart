import 'package:stripe_payment/stripe_payment.dart';

class StripeTransactionResponse {

  String message;
  bool success;
  PaymentMethod paymentMethod;

  StripeTransactionResponse({
    required this.message,
    required this.success,
    required this.paymentMethod
  });

}