import 'package:flutter/material.dart';
import 'package:playstack/screens/AccessScreen.dart';
import 'package:playstack/screens/RegisterScreen.dart';
import 'package:playstack/screens/mainscreen.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //final user = Provider.of<User>(context);
    final String user = null;

    // return either the Home or Authenticate widget
    /*if (user == null) {
      return AccessScreen();
    } else {
      return AccessScreen();
    }
    */
     return RegisterScreen();
  }
}
