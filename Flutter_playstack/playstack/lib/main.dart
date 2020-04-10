import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:playstack/screens/Homescreen/Settings.dart';
import 'package:playstack/screens/Search/SearchProcess.dart';
import 'package:playstack/screens/authentication/Register.dart';
import 'package:playstack/screens/authentication/RegisterScreen.dart';
import 'package:playstack/screens/mainscreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: 'Poppins',
          textTheme: TextTheme(title: TextStyle(fontFamily: 'Circular'))),
      home: MainScreen(),
      routes: {
        'mainscreen': (context) => MainScreen(),
        'searchProcessScreen': (_) => SearchProcess(),
        'Register': (_) => RegisterScreen(),
        'Settings': (_) => Settings()
      },
    );
  }
}
