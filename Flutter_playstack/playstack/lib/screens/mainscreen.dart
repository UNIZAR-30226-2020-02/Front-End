import 'package:flutter/material.dart';
import 'package:playstack/screens/ExampleApp.dart';
import 'package:playstack/screens/Homescreen/Home.dart';
import 'package:playstack/screens/Library.dart';
import 'package:playstack/screens/Search/SearchScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:playstack/screens/authentication/AccessScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:playstack/services/auth.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  SharedPreferences sharedPreferences;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLoginStatus();
  }

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => AccessScreen()),
          (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: show(_currentIndex),
      bottomNavigationBar: SizedBox(
        height: 90,
        child: BottomNavigationBar(
            fixedColor: Colors.red[600],
            currentIndex: _currentIndex,
            onTap: (int index) {
              setState(() {
                _currentIndex = index;
                show(index);
              });
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

Widget show(int index) {
  switch (index) {
    case 0:
      return HomeScreen();
      break;
    case 1:
      return SearchScreen();
      break;
    case 2:
      return Library();
      break;
    case 3:
      return ExampleApp();
      break;
  }
}
