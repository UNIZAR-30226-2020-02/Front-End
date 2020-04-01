import 'package:flutter/material.dart';
import 'package:playstack/screens/Home.dart';
import 'package:playstack/screens/SearchScreen.dart';
import 'package:playstack/services/auth.dart';
import 'package:flutter/cupertino.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: show(_currentIndex),
      bottomNavigationBar: SizedBox(
        height: 75,
        child: BottomNavigationBar(
            fixedColor: Colors.red[600],
            backgroundColor: Colors.grey[900],
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
  }
}
