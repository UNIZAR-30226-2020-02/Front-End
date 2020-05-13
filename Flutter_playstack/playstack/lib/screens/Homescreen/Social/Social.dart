import 'package:flutter/material.dart';
import 'package:playstack/services/database.dart';
import 'package:playstack/screens/Homescreen/Social/SearchPeople.dart';
import 'package:playstack/shared/Loading.dart';
import 'package:playstack/shared/common.dart';

class Social extends StatefulWidget {
  @override
  _SocialState createState() => _SocialState();
}

class _SocialState extends State<Social> {
  bool _loadingFollowing = true;
  bool _loadingFollowers = true;
  bool _loadingFollowRequests = true;

  List followRequests = new List();

  @override
  void initState() {
    super.initState();
    getFollowing();
    getFollowers();
    getFollowRequests();
  }

  void getFollowing() async {
    following = await getUsersFollowingDB();
    if (!leftAlready) {
      setState(() {
        _loadingFollowing = false;
      });
    }
  }

  void getFollowers() async {
    followers = await getFollowersDB();

    if (!leftAlready) {
      setState(() {
        _loadingFollowers = false;
      });
    }
  }

  void getFollowRequests() async {
    followRequests = await listFollowRequests();

    if (!leftAlready) {
      setState(() {
        _loadingFollowRequests = false;
      });
    }
  }

  Widget showList(String listName) {
    switch (listName) {
      case "Following":
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: following.isEmpty ? 0 : following.length,
            itemBuilder: (BuildContext context, int index) {
              return new UserTile(following[index], "Following");
            },
          ),
        );

        break;

      case "Followers":
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: followers.isEmpty ? 0 : followers.length,
            itemBuilder: (BuildContext context, int index) {
              return new UserTile(followers[index], "Followers");
            },
          ),
        );

        break;

      default:
        return ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: followRequests.isEmpty ? 0 : followRequests.length,
          itemBuilder: (BuildContext context, int index) {
            return new UserTile(followRequests[index], "Requests");
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Color(0xFF191414),
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                leftAlready = true;
                homeIndex.value = 0;
              }),
          backgroundColor: Colors.transparent,
          bottomOpacity: 1.0,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  leftAlready = false;
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => SearchPeople()));
                })
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
          children: [
            _loadingFollowing ? LoadingSongs() : showList("Following"),
            _loadingFollowers ? LoadingSongs() : showList('Followers'),
            _loadingFollowRequests ? LoadingSongs() : showList('FollowRequests')
          ],
        ),
      ),
    );
  }
}
