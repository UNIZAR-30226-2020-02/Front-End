import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
            backgroundColor: Colors.transparent,
            body: ListView(
              children: <Widget>[
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Container(
                              height: 40,
                              width: 40,
                              child: Image.asset('lib/assets/Photos/logo.png')),
                          SizedBox(width: 70),
                          FlatButton.icon(
                              onPressed: null,
                              icon: Icon(CupertinoIcons.settings_solid),
                              label: Text('')),
                        ],
                      ),
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
                                    'lib/assets/Photos/logo.png',
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
                    ],
                  ),
                )
              ],
            )));
  }
}

/*
return Scaffold(
        appBar: AppBar(
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
                FlatButton.icon(
                    onPressed: null,
                    icon: Icon(CupertinoIcons.settings_solid),
                    label: Text(''))
              ],
            ),

*/
