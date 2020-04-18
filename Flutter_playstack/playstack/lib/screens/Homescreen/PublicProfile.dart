import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:playstack/shared/common.dart';

class YourPublicProfile extends StatefulWidget {
  @override
  _YourPublicProfileState createState() => _YourPublicProfileState();
}

class _YourPublicProfileState extends State<YourPublicProfile> {
  List mostListenedTo;
  List likedGenres;
  List lastListenedTo;

  _YourPublicProfileState() {
    mostListenedTo = new List();
    likedGenres = new List();
    lastListenedTo = new List();
  }
  @override
  void initState() {
    super.initState();
    //TODO: descomentar
    /* getListsData('mostListenedTo');
    getListsData('likedGenres');
    getListsData('lastListenedTo'); */
  }

  void addToList(String item, String list) {
    switch (list) {
      case 'mostListenedTo':
        mostListenedTo.add(item);
        break;
      case 'likedGenres':
        likedGenres.add(item);
        break;
      default:
        lastListenedTo.add(item);
    }
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
      default:
        print("ultimas canciones y podcasts...");
        response = await http.get(
          "https://playstack.azurewebsites.net/get/song/bygenre?user=$userName",
          headers: {"Content-Type": "application/json"},
        );
    }

    print("Statuscode " + response.statusCode.toString());
    //print("Body:" + response.body.toString());
    if (response.statusCode == 200) {
      response = jsonDecode(response.body);
      //response.forEach((title, info) => print(title + info.toString()));
      for (var item in response) {
        addToList(item, list);
      }

      /* setState(() {
        _loading = false;
      }); */
    } else {
      print(response.body);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  userName,
                  style: TextStyle(fontSize: 25),
                ),
                SizedBox(height: 10),
                ProfilePicture()
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
