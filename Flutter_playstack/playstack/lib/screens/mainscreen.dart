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

//import 'package:playstack/services/auth.dart';

class MainScreen extends StatefulWidget {
  /* //Singleton
  static final MainScreen _mainScreen = MainScreen._constructor();
  factory MainScreen() => _mainScreen;
  MainScreen._constructor();

  final MainScreenState _mainScreenState = MainScreenState(); */
  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  SharedPreferences sharedPreferences;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    checkAccountType();
    getUserData();
    createLocalDatabase();
  }

  void getUserData() async {
    bool _res1 = false,
        _res2 = true; //MUST BE SET TO FALSE, TEMPORARY WORKAROUND
    if (imagePath == null) {
      _res1 = await getProfilePhoto();
    }
    /*if (currentAudio == null) {
      print("Va a setear la ultima cancion");
      _res2 = await setLastSongAsCurrent();
    }*/
    if (_res1 && _res2) {
      setState(() {
        loadingUserData = false;
      });
    }
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
              body: loadingUserData
                  ? Loading()
                  : extendedBottomBarWith(context, show(currentIndex.value)),
              bottomNavigationBar: loadingUserData ? null : bottomBar(context));
        });
  }
}
