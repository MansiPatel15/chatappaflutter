import 'package:flutter/material.dart';

class ThankYou extends StatefulWidget {

  @override
  State<ThankYou> createState() => _ThankYouState();
}

class _ThankYouState extends State<ThankYou> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ThankYou...."),
      ),
      body: Center(
        child: Container(
          child:
              Image.asset("image/t1.jpg"),
        ),
      ),
    );
  }
}
