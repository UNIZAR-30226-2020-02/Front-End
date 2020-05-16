import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playstack/screens/GenresSongs.dart';
import 'package:playstack/screens/Homescreen/HomeScreenElements.dart';
import 'package:playstack/screens/Homescreen/Settings.dart';
import 'package:playstack/screens/Homescreen/Social/Social.dart';
import 'package:playstack/screens/Library/ArtistSongs.dart';
import 'package:playstack/services/database.dart';
import 'package:playstack/shared/common.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<String> imageurl = [
  'assets/images/Artists/Macklemore.jpg',
  'assets/images/Artists/Eminem.jpg',
  'assets/images/Artists/datweekaz.jpg',
  'assets/images/Artists/timmytrumpet.jpg'
];
List<String> artists = ['Macklemore', 'Eminem', 'Da Tweekaz', 'Timmy Trumpet'];

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SharedPreferences sharedPreferences;

  Widget artistsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
          child: Text(
            "Artistas",
            style: TextStyle(fontFamily: 'Circular', fontSize: 22),
          ),
        ),
        Container(
          height: 165.0,
          child: ListView.builder(
            itemCount: imageurl.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              return ArtistItem(artists[index], imageurl[index]);
            },
          ),
        )
      ],
    );
  }

  Widget startHome() {
    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Color.fromRGBO(80, 20, 20, 4.0),
            Color(0xFF191414),
          ], begin: Alignment.topLeft, end: FractionalOffset(0.3, 0.3)),
        ),
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(CupertinoIcons.group_solid),
                onPressed: () {
                  leftAlready = false;
                  homeIndex.value = 1;
                },
              ),
              title: Container(
                  height: 40,
                  width: 40,
                  child: Image.asset('lib/assets/Photos/logo.png')),
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10.0),
              ),
              actions: <Widget>[
                IconButton(
                    icon: Icon(CupertinoIcons.settings),
                    onPressed: () => homeIndex.value = 2)
              ],
            ),
            backgroundColor: Colors.transparent,
            body: ListView(
              children: <Widget>[
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[genres(), artistsCards()],
                  ),
                )
              ],
            )));
  }

  Widget showHome(int index) {
    Widget result;
    switch (index) {
      case 0:
        result = startHome();
        break;
      case 1:
        result = Social();
        break;
      case 2:
        result = Settings();
        break;
      case 3:
        result = GenresSongs(genre: currentGenre, image: currentGenreImage);
        break;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: homeIndex,
        builder: (BuildContext context, int value, Widget child) {
          return WillPopScope(
              onWillPop: () async {
                homeIndex.value = 0;
                return false;
              },
              child: showHome(homeIndex.value));
        });
  }
}
