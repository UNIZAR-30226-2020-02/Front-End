import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:playstack/screens/Homescreen/ProfileSettings.dart';
import 'package:playstack/screens/Homescreen/PublicProfile.dart';
import 'package:playstack/screens/Homescreen/Settings.dart';
import 'package:playstack/screens/Search/SearchProcess.dart';
import 'package:playstack/screens/authentication/AccessScreen.dart';
import 'package:playstack/screens/authentication/RegisterScreen.dart';
import 'package:playstack/screens/mainscreen.dart';
import 'package:bot_toast/bot_toast.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BotToastInit(
      child: MaterialApp(
        navigatorObservers: [BotToastNavigatorObserver()],
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            brightness: Brightness.dark,
            fontFamily: 'Poppins',
            textTheme: TextTheme(title: TextStyle(fontFamily: 'Circular'))),
        home: MainScreen(),
        initialRoute: 'access',
        routes: {
          'access': (_) => AccessScreen(),
          'mainscreen': (context) => MainScreen(),
          'searchProcessScreen': (_) => SearchProcess(),
          'Register': (_) => RegisterScreen(),
          'Settings': (_) => Settings(),
          'ProfileSettings': (_) => ProfileSettings(),
        },
      ),
    );
  }
}