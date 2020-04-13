import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playstack/screens/Homescreen/HomeScreenElements.dart';
import 'package:playstack/screens/authentication/AccessScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SharedPreferences sharedPreferences;

  @override
  Widget build(BuildContext context) {
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
                    onPressed: () =>
                        Navigator.of(context).pushNamed('Settings'))
              ],
            ),
            backgroundColor: Colors.transparent,
            body: ListView(
              children: <Widget>[
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      genres(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                        child: Text(
                          "Made for you",
                          style:
                              TextStyle(fontFamily: 'Circular', fontSize: 20),
                        ),
                      ),
                      Container(
                        height: 165.0,
                        child: ListView.builder(
                          itemCount: 10,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 130.0,
                                  width: 140.0,
                                  child: Image.asset(
                                    'lib/assets/Photos/pic1.png',
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                                Padding(padding: EdgeInsets.all(5.0)),
                                Text(
                                  'Curtain Call',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(1.0),
                                    fontFamily: 'Circular',
                                    fontSize: 10.0,
                                  ),
                                )
                              ],
                            );
                          },
                        ),
                      ),
                      Container(
                        height: 250.0,
                        child: Column(
                          children: <Widget>[
                            Text(
                              'Recommendation',
                              style: TextStyle(
                                color: Colors.white.withOpacity(1.0),
                                fontSize: 23.0,
                                fontFamily: 'Circular',
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10.0),
                            ),
                            Container(
                              height: 165.0,
                              child: ListView.builder(
                                itemCount: imageurl.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (BuildContext context, int index) {
                                  return Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 130.0,
                                        width: 140.0,
                                        child: Image.asset(
                                          imageurl[index],
                                          fit: BoxFit.fitHeight,
                                        ),
                                      ),
                                      Padding(padding: EdgeInsets.all(5.0)),
                                      Text(
                                        txt[index],
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(1.0),
                                          fontFamily: 'Circular',
                                          fontSize: 10.0,
                                        ),
                                      )
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            )));
  }
}

List<String> imageurl = [
  'lib/assets/Photos/pic1.png',
  'lib/assets/Photos/i2.jpeg',
  'lib/assets/Photos/i3.jpeg',
];
List<String> txt = [
  'Curtain Call',
  "The Eminem show",
  'Greatest Hits',
];
