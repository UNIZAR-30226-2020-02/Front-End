import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:playstack/services/database.dart';
import 'package:playstack/shared/Loading.dart';

import 'package:playstack/shared/common.dart';

class YourPublicProfile extends StatefulWidget {
  final bool own;
  final String friendUserName;
  YourPublicProfile(this.own, {this.friendUserName});
  @override
  _YourPublicProfileState createState() =>
      _YourPublicProfileState(own, friendUserName);
}

class _YourPublicProfileState extends State<YourPublicProfile> {
  final bool own;
  final String friendUserName;

  bool _loading = true;
  bool alreadyFollowing = false;

  String friendProfilePhoto;

  List mostListenedTo;
  List likedGenres;
  List lastListenedTo;
  List publicPlaylists;

  _YourPublicProfileState(this.own, this.friendUserName) {
    mostListenedTo = new List();
    likedGenres = new List();
    lastListenedTo = new List();
    publicPlaylists = new List();
  }
  @override
  void initState() {
    super.initState();
    if (!own) {
      getPhoto();
    } else {
      setState(() {
        _loading = false;
      });
    }
    //TODO: descomentar
    getListsData('publicPlaylists');
    /*
     getListsData('mostListenedTo');
    
    getListsData('likedGenres');
    getListsData('lastListenedTo'); */
  }

  void getPhoto() async {
    friendProfilePhoto = await getForeignPicture(friendUserName);
    alreadyFollowing = await checkIfFollowing(friendUserName);
    setState(() {
      _loading = false;
    });
  }

  Future<void> getListsData(String list) async {
    dynamic response;

    //TODO: poner URLs
    switch (list) {
      case 'mostListenedTo':
        print("Recopilando las mas escuchadas...");
        response = await http.get(
          "https://playstack.azurewebsites.net/get/song/bygenre?user=$userName",
          headers: {"Content-Type": "application/json"},
        );
        break;
      case 'likedGenres':
        print("Recopilando generos favoritos...");
        response = await http.get(
          "https://playstack.azurewebsites.net/get/song/bygenre?user=$userName",
          headers: {"Content-Type": "application/json"},
        );
        break;
      case 'publicPlaylists':
        if (own) {
          publicPlaylists = await getpublicPlaylistsDB(own);
        } else {
          publicPlaylists =
              await getpublicPlaylistsDB(own, user: friendUserName);
        }

        break;
      default:
        print("ultimas canciones y podcasts...");
        response = await http.get(
          "https://playstack.azurewebsites.net/get/song/bygenre?user=$userName",
          headers: {"Content-Type": "application/json"},
        );
    }
    setState(() {});
  }

  Widget listItems(String list) {
    switch (list) {
      case 'mostListenedTo':
        return ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: mostListenedTo.isEmpty ? 0 : mostListenedTo.length,
          itemBuilder: (BuildContext context, int index) {
            return new ListTile(title: mostListenedTo[index]);
          },
        );
        break;
      case 'likedGenres':
        return ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: likedGenres.isEmpty ? 0 : likedGenres.length,
          itemBuilder: (BuildContext context, int index) {
            return new ListTile(title: likedGenres[index]);
          },
        );
        break;

      case 'publicPlaylists':
        return ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: publicPlaylists.isEmpty ? 0 : publicPlaylists.length,
          itemBuilder: (BuildContext context, int index) {
            return new PlaylistItem(
              publicPlaylists[index],
              true,
            );
          },
        );
        break;
      default:
        return ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: lastListenedTo.isEmpty ? 0 : lastListenedTo.length,
          itemBuilder: (BuildContext context, int index) {
            return new ListTile(title: lastListenedTo[index]);
          },
        );
    }
  }

  Widget followButton(BuildContext context) {
    return !own
        ? Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Container(
              height: 35.0,
              width: MediaQuery.of(context).size.width / 3,
              child: RaisedButton(
                onPressed: () async {
                  if (!alreadyFollowing) {
                    bool followed = await follow(friendUserName);
                    if (followed) {
                      BotToast.showText(text: "Seguido");

                      setState(() {
                        alreadyFollowing = true;
                      });
                      following = await getUsersFollowingDB();
                    } else {
                      BotToast.showText(text: "Error siguiendo");
                    }
                  }
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(80.0)),
                padding: EdgeInsets.all(0.0),
                child: Ink(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red[800],
                          Colors.red[300],
                          Colors.red[800]
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Container(
                    constraints:
                        BoxConstraints(maxWidth: 300.0, minHeight: 50.0),
                    alignment: Alignment.center,
                    child:
                        Text(alreadyFollowing ? "Dejar de seguir" : "Seguir"),
                  ),
                ),
              ),
            ),
          )
        : Text('');
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(centerTitle: true, title: Text('Tu perfil')),
            body: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Center(
                      child: Column(
                    children: <Widget>[
                      Text(
                        own ? userName : friendUserName,
                        style: TextStyle(fontSize: 25),
                      ),
                      SizedBox(height: 10),
                      own
                          ? ProfilePicture()
                          : CircleAvatar(
//backgroundColor: Color(0xFF191414),
                              radius: 60,
                              backgroundImage:
                                  NetworkImage(friendProfilePhoto)),
                      followButton(context)
                    ],
                  )),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Canciones y podcasts más escuchados",
                        style: TextStyle(fontSize: 20),
                      ),
                      listItems('mostListenedTo'),
                      Text(
                        "Géneros más escuchados",
                        style: TextStyle(fontSize: 20),
                      ),
                      listItems('likedGenres'),
                      Text(
                        "Listas de reproducción públicas",
                        style: TextStyle(fontSize: 20),
                      ),
                      listItems('publicPlaylists'),
                      Text(
                        "Últimas canciones y podcast escuchados",
                        style: TextStyle(fontSize: 20),
                      ),
                      listItems('lastListenedTo'),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
