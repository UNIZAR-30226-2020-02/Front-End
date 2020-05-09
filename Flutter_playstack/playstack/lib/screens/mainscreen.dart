import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:playstack/screens/Player/PlayerWidget.dart';
import 'package:playstack/screens/Player/PlayingNow.dart';
import 'package:playstack/screens/authentication/AccessScreen.dart';
import 'package:playstack/shared/common.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:playstack/models/Song.dart';

//import 'package:playstack/services/auth.dart';

class MainScreen extends StatefulWidget {
  //Singleton
  static final MainScreen _mainScreen = MainScreen._constructor();
  factory MainScreen() => _mainScreen;
  MainScreen._constructor();

  final MainScreenState _mainScreenState = MainScreenState();
  @override
  MainScreenState createState() => _mainScreenState;
}

class MainScreenState extends State<MainScreen> {
  SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("LoggedIn") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => AccessScreen()),
          (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: extendedBottomBarWith(context, show(currentIndex)),
        bottomNavigationBar: bottomBar(context));
  }
}
