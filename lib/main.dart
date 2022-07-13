import 'package:chatapp/GoogleMapExample.dart';
import 'package:chatapp/LoginScreen.dart';
import 'package:chatapp/SplashScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'OnlinePayment.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.teal,
      ),
      home:LoginScreen(),
    );
  }
}

