import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:playstack/screens/Player/PlayerWidget.dart';
import 'package:playstack/screens/Player/PlayingNow.dart';
import 'package:playstack/screens/authentication/AccessScreen.dart';
import 'package:playstack/services/SQLite.dart';
import 'package:playstack/services/database.dart';
import 'package:playstack/shared/Loading.dart';
import 'package:playstack/shared/common.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:playstack/models/Song.dart';
import 'package:toast/toast.dart';

//import 'package:playstack/services/auth.dart';

class MainScreen extends StatefulWidget {
  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  SharedPreferences sharedPreferences;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    setState(() => _loading = true);
    Future<String> futureString = loadLanguagesString();
    futureString.then((value) {
      languageStrings = jsonDecode(value);
      print("Loaded ${languageStrings['language']}");
      setState(() => _loading = false);
    });
    checkLoginStatus();
  }

  void getUserData() async {
    bool _res1 = false, _res2 = false;

    _res1 = await getProfilePhoto();

    _res2 = await setLastSongAsCurrent();
    songsNextUp = new List();
    songsNextUpName = "Último escuchado";

    if (_res1 && _res2) {
      if (mounted)
        setState(() {
          loadingUserData = false;
        });
    } else {
      Toast.show('Error obteniendo datos del usuario!', context,
          gravity: Toast.CENTER,
          duration: Toast.LENGTH_LONG,
          backgroundColor: Colors.red);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => AccessScreen()),
          (Route<dynamic> route) => false);
    }
  }

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    userName = sharedPreferences.getString("UserName");
    userEmail = sharedPreferences.getString("UserEmail");
    if (sharedPreferences.getString("LoggedIn") == null || userName == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => AccessScreen()),
          (Route<dynamic> route) => false);
    } else {
      print("Username was set to " + userName);
      checkAccountType();
      getUserData();
      createLocalDatabase();
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
            currentIndex: currentIndex.value,
            onTap: (int index) {
              currentIndex.value = index;
              if (index == 3) {
                Navigator.of(context).push(MaterialPageRoute(
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
    return ValueListenableBuilder(
        valueListenable: currentIndex,
        builder: (BuildContext context, int value, Widget child) {
          return Scaffold(
              body: loadingUserData || _loading
                  ? Loading()
                  : extendedBottomBarWith(context, show(currentIndex.value)),
              bottomNavigationBar: loadingUserData ? null : bottomBar(context));
        });
  }
}
