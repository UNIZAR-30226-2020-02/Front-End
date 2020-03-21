import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:playstack/screens/mainscreen.dart';
import 'package:playstack/screens/wrapper.dart';

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
      home: Wrapper(),
      routes: {'mainscreen': (context) => MainScreen()},
    );
  }
}
