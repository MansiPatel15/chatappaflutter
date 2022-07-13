import 'package:chatapp/ErrorPage.dart';
import 'package:chatapp/ThankYou.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class OnlinePayment extends StatefulWidget {
  @override
  State<OnlinePayment> createState() => _OnlinePaymentState();
}

class _OnlinePaymentState extends State<OnlinePayment> {
  TextEditingController _amt = TextEditingController();

  static const platform = const MethodChannel("razorpay_flutter");
  Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Success Response: '+response.paymentId);
   // Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context)=> ThankYou())
    );
    // Thank you
    /*Fluttertoast.showToast(
        msg: "SUCCESS: " + response.paymentId!,
        toastLength: Toast.LENGTH_SHORT); */
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Error Response: $response');
  //  Navigator.of(context).pop();
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context)=> ErrorPage())
    );
    /* Fluttertoast.showToast(
        msg: "ERROR: " + response.code.toString() + " - " + response.message!,
        toastLength: Toast.LENGTH_SHORT); */
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External SDK Response: $response');
    /* Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName!,
        toastLength: Toast.LENGTH_SHORT); */
  }
  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("OnlinePayment..."),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Amount : ",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: _amt,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
            SizedBox(
              height: 50,
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(onPressed: () {


                  var amt = _amt.text.toString();

                  var options = {
                    'key': 'rzp_test_z8H1APaYHfu5Sp',
                    'amount': double.parse(amt) * 100,
                    'name': 'Shopping Payment',
                    'description': 'Fine T-Shirt',
                    'retry': {'enabled': true, 'max_count': 1},
                    'send_sms_hash': true,
                    'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
                    'external': {
                      'wallets': ['paytm']
                    }
                  };

                  try {
                    _razorpay.open(options);
                  } catch (e) {
                    debugPrint('Error: e');
                  }


                  }, child: Text("Payment")) ,
              ),
            )
          ],
        ),
      ),
    );
  }
}
