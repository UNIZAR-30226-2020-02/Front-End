import 'package:flutter/material.dart';
import 'package:playstack/screens/AccessScreen.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //final user = Provider.of<User>(context);
    final String user = null;

    // return either the Home or Authenticate widget
    if (user == null) {
      return AccessScreen();
    } else {
      return AccessScreen();
    }
  }
}
