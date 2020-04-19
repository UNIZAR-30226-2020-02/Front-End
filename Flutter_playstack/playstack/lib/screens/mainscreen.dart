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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: show(currentIndex),
      bottomNavigationBar: SizedBox(
        height: MediaQuery.of(context).size.height / 9,
        child: BottomNavigationBar(
            fixedColor: Colors.red[600],
            currentIndex: currentIndex,
            onTap: (int index) {
              if (index == 3) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => PlayingNowScreen()));
              } else {
                setState(() {
                  currentIndex = index;
                  show(index);
                });
              }
            },
            type: BottomNavigationBarType.shifting,
            items: [
              BottomNavigationBarItem(
                  icon: new Icon(
                    CupertinoIcons.home,
                    size: 25,
                  ),
                  title: new Text(
                    "Home",
                    style: TextStyle(fontSize: 10),
                  )),
              BottomNavigationBarItem(
                  icon: new Icon(CupertinoIcons.search, size: 25),
                  title: new Text(
                    "Search",
                    style: TextStyle(fontSize: 10),
                  )),
              BottomNavigationBarItem(
                  icon: new Icon(CupertinoIcons.collections, size: 25),
                  title: new Text(
                    "Library",
                    style: TextStyle(fontSize: 10),
                  )),
              BottomNavigationBarItem(
                  icon: new Icon(CupertinoIcons.music_note),
                  title: new Text("Play", style: TextStyle(fontSize: 10))),
            ]),
      ),
    );
  }
}
