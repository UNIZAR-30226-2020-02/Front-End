import 'package:flutter/material.dart';
import 'package:playstack/models/user.dart';
import 'package:playstack/screens/Homescreen/PublicProfile.dart';
import 'package:playstack/services/database.dart';
import 'package:playstack/screens/Homescreen/Social/SearchPeople.dart';
import 'package:playstack/shared/Loading.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:playstack/shared/common.dart';
import 'package:toast/toast.dart';

class Social extends StatefulWidget {
  @override
  _SocialState createState() => _SocialState();
}

class _SocialState extends State<Social> {
  bool _loadingFollowing = true;
  bool _loadingFollowers = true;
  bool _loadingFollowRequests = true;
  bool _applying = false;

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
    if (mounted)
      setState(() {
        _loadingFollowing = false;
      });
  }

  Future<void> getFollowers() async {
    followers = await getFollowersDB();

    if (mounted)
      setState(() {
        _loadingFollowers = false;
      });
  }

  Future<void> getFollowRequests() async {
    followRequests = await listFollowRequests();
    if (mounted)
      setState(() {
        _loadingFollowRequests = false;
      });
  }

  Widget followRequestButtons(User user, context) {
    var _width = MediaQuery.of(context).size.width / 2;
    return Container(
      width: _width,
      child: Row(
        children: <Widget>[
          Container(
            width: _width / 2.3,
            child: RaisedButton(
              onPressed: () async {
                setState(() {
                  _applying = true;
                });
                bool res = await follow(user.title);
                if (res) {
                  Toast.show("Solicitud aceptada correctamente", context,
                      gravity: Toast.CENTER,
                      backgroundColor: Colors.grey,
                      duration: Toast.LENGTH_LONG);
                  await getFollowRequests();
                  await getFollowers();
                } else {
                  Toast.show("Error aceptando solicitud", context,
                      gravity: Toast.CENTER,
                      backgroundColor: Colors.grey,
                      duration: Toast.LENGTH_LONG);
                }
                setState(() {
                  _applying = false;
                });
              },
              child: Text("Aceptar"),
              color: Colors.lime[500],
            ),
          ),
          SizedBox(
            width: 15,
          ),
          Container(
            width: _width / 2.1,
            child: RaisedButton(
              onPressed: () async {
                setState(() {
                  _applying = true;
                });
                bool res = await rejectFollowRequest(user.title);
                if (res) {
                  Toast.show("Solicitud rechazada correctamente", context,
                      gravity: Toast.CENTER,
                      backgroundColor: Colors.grey,
                      duration: Toast.LENGTH_LONG);
                  await getFollowRequests();
                } else {
                  Toast.show("Error rechazando solicitud", context,
                      gravity: Toast.CENTER,
                      backgroundColor: Colors.grey,
                      duration: Toast.LENGTH_LONG);
                }
                setState(() {
                  _applying = false;
                });
              },
              child: Text("Rechazar"),
              color: Colors.red[500],
            ),
          )
        ],
      ),
    );
  }

  Widget userTile(User user, String tab) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      child: ListTile(
          leading: CircleAvatar(
              radius: 30, backgroundImage: NetworkImage(user.photoUrl)),
          title: Text(user.title),
          trailing: tab == "Requests"
              ? followRequestButtons(user, context)
              : Text(''),
          onTap: () {
            viewingOwnPublicProfile = false;
            previousIndex = homeIndex.value;
            friendUserName = user.title;
            otherUser = user;
            homeIndex.value = 6;
          }),
    );
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
              return userTile(following[index], "Following");
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
              return userTile(followers[index], "Followers");
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
            return userTile(followRequests[index], "Requests");
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
                homeIndex.value = 0;
              }),
          backgroundColor: Colors.transparent,
          bottomOpacity: 1.0,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  previousIndex = homeIndex.value;
                  homeIndex.value = 7;
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
        body: ModalProgressHUD(
          opacity: 0,
          child: Scaffold(
            floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.red[400],
                child: Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
                onPressed: () async {
                  setState(() {
                    _loadingFollowing = true;
                    _loadingFollowers = true;
                    _loadingFollowRequests = true;
                  });
                  getFollowing();
                  getFollowers();
                  getFollowRequests();
                }),
            backgroundColor: Colors.transparent,
            body: TabBarView(
              children: [
                _loadingFollowing ? LoadingSongs() : showList("Following"),
                _loadingFollowers ? LoadingSongs() : showList('Followers'),
                _loadingFollowRequests
                    ? LoadingSongs()
                    : showList('FollowRequests')
              ],
            ),
          ),
          inAsyncCall: _applying,
        ),
      ),
    );
  }
}
