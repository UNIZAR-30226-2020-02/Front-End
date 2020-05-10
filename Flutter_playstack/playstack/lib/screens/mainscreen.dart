import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:playstack/screens/Player/PlayingNow.dart';
import 'package:playstack/screens/authentication/AccessScreen.dart';
import 'package:playstack/shared/common.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:playstack/services/auth.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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

  Widget bottomBar(context) {
    double height = MediaQuery.of(context).size.height / 10;
    double iconsize = height / 3.2;
    double textsize = height / 10;
    return SizedBox(
        height: height,
        child: BottomNavigationBar(
            fixedColor: Colors.red[600],
            currentIndex: currentIndex,
            onTap: (int index) {
              currentIndex = index;
              if (index == 3) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (BuildContext context) => PlayingNowScreen()));
              }
              setState(() {});
            },
            type: BottomNavigationBarType.shifting,
            items: [
              BottomNavigationBarItem(
                  icon: new Icon(
                    CupertinoIcons.home,
                    size: iconsize,
                  ),
                  title: new Text(
                    "Home",
                    style: TextStyle(fontSize: textsize),
                  )),
              BottomNavigationBarItem(
                  icon: new Icon(CupertinoIcons.search, size: iconsize),
                  title: new Text(
                    "Search",
                    style: TextStyle(fontSize: textsize),
                  )),
              BottomNavigationBarItem(
                  icon: new Icon(CupertinoIcons.collections, size: iconsize),
                  title: new Text(
                    "Library",
                    style: TextStyle(fontSize: textsize),
                  )),
              BottomNavigationBarItem(
                  icon: new Icon(CupertinoIcons.music_note, size: iconsize),
                  title:
                      new Text("Play", style: TextStyle(fontSize: textsize))),
            ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: show(currentIndex), bottomNavigationBar: bottomBar(context));
  }
}
