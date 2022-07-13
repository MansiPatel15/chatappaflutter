import 'package:flutter/material.dart';

class ErrorPage extends StatefulWidget {

  @override
  State<ErrorPage> createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ErrorPage.."),
      ),
      body: Center(
        child: Container(
          child:
          Text("Error...",style: TextStyle(fontSize: 60,fontWeight: FontWeight.bold),),
        ),
      ),
    );
  }
}
