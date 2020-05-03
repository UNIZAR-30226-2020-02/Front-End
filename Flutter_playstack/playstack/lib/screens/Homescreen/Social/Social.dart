import 'package:flutter/material.dart';
import 'package:playstack/services/database.dart';
import 'package:playstack/screens/Homescreen/Social/SearchPeople.dart';

class Social extends StatefulWidget {
  @override
  _SocialState createState() => _SocialState();
}

class _SocialState extends State<Social> {
  List following = new List();
  List followers = new List();

  @override
  void initState() {
    super.initState();
    getFollowers();
  }

  void getFollowers() async {
    followers = await getFollowersDB();
    setState(() {});
  }

  Widget showFollowers() {}

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Color(0xFF191414),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          bottomOpacity: 1.0,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.search),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => SearchPeople())))
          ],
          bottom: TabBar(
            indicatorColor: Colors.orange[800],
            tabs: [
              Tab(
                child: Text(
                  'Siguiendo',
                  style: TextStyle(fontFamily: 'Circular', fontSize: 20),
                ),
              ),
              Tab(
                child: Text(
                  'Seguidores',
                  style: TextStyle(fontFamily: 'Circular', fontSize: 20),
                ),
              ),
              Tab(
                child: Text(
                  'Solicitudes',
                  style: TextStyle(fontFamily: 'Circular', fontSize: 20),
                ),
              ),
            ],
          ),
          title: Text(
            "Social",
            style: TextStyle(fontFamily: 'Circular'),
          ),
        ),
        body: TabBarView(
          children: [Center(child: Text('tab1')), Text('tab2'), Text('Tab3')],
        ),
      ),
    );
  }
}
