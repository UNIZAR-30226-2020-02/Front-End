import 'package:flutter/material.dart';
import 'package:playstack/services/auth.dart';

class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MainScreenState();
  }
}

class _MainScreenState extends State<MainScreen> {
  final AuthService _auth = AuthService();

  int _currentIndex = 0;
  final List<Widget> _children = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(Icons.person),
              label: Text('logout'),
              onPressed: () async {
                //await _auth.signOut();
              },
            ),
          ],
          centerTitle: true,
          title: Padding(
            padding: const EdgeInsets.fromLTRB(85, 0, 0, 0),
            child: new Center(
                child: new Text('BubbleChat',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.deepOrange, fontFamily: 'Bellota'))),
          )),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex:
            _currentIndex, // this will be set when a new tab is tapped
        onTap: tabbed,
        fixedColor: Colors.deepOrange,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
              icon: new Icon(Icons.camera_alt), title: new Text("")),
          BottomNavigationBarItem(
              icon: new Icon(Icons.chat_bubble_outline), title: new Text("")),
          BottomNavigationBarItem(
              icon: new Icon(Icons.group), title: new Text("")),
        ],
      ),
    );
  }

  void tabbed(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
