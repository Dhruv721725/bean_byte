import 'package:bean_byte/components/alert_comp.dart';
import 'package:bean_byte/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentGate {
  final BuildContext context;
  final UserModel user;
  Function(String?) onSuccess;
  PaymentGate({
    required this.context,
    required this.user,
    required this.onSuccess,
  });

  void showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertComp(title: "Bean & Byte", message: message),
    );
  }

  Future<void> initiatePayment(double amount) async {
    Razorpay razorpay = Razorpay();
    Map<String, dynamic> options = {
      'key': 'rzp_test_QBdS7Hni9XQerM',
      'amount': (amount * 100).toInt(),
      'name': 'Bean Byte',
      'description': 'Payment for your order',
      'retry': {'enabled': true, 'max_count': 3},
      'send_sms_hash': true,
      'prefill': {'contact': user.phone, 'email': user.email},
      'external': {
        'wallets': ['paytm'],
      },
    };
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);
    razorpay.open(options);
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    /*
    * PaymentFailureResponse contains three values:
    * 1. Error Code
    * 2. Error Description
    * 3. Metadata
    * */
    print(
      "Code: ${response.code}\nDescription: ${response.message}\nMetadata:${response.error.toString()}",
    );
    showAlert("Payment Failed");
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    /*
    * Payment Success Response contains three values:
    * 1. Order ID
    * 2. Payment ID
    * 3. Signature
    * */
    onSuccess(response.paymentId);
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {
    showAlert("${response.walletName}");
  }
}
