import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playstack/services/database.dart';
import 'package:playstack/shared/common.dart';
import 'dart:ui' as ui;

class Playlist extends StatefulWidget {
  final name;
  Playlist(this.name);

  @override
  _PlaylistState createState() => _PlaylistState(name);
}

class _PlaylistState extends State<Playlist> {
  final String name;
  List songs = new List();

  _PlaylistState(this.name);

  @override
  void initState() {
    super.initState();
    getSongs();
  }

  void getSongs() async {
    if (name == "Favoritas") {
      songs = await getFavoriteSongs();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.red[900].withOpacity(0.7),
            Color(0xFF191414),
            Color(0xFF191414),
            Color(0xFF191414),
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              name,
              style: TextStyle(fontSize: 25, fontFamily: 'Circular'),
            ),
            backgroundColor: Colors.transparent,
            leading: IconButton(
                icon: Icon(CupertinoIcons.back),
                onPressed: () => Navigator.of(context).pop()),
          ),
          backgroundColor: Colors.transparent,
          body: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    //TODO : cambiar segunda opcion a cover de la playlist
                    name == "Favoritas"
                        ? Image.asset("assets/images/Favs_cover.jpg")
                        : Image.asset("assets/images/defaultCover.png"),
                    BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        height: MediaQuery.of(context).size.height / 3,
                        width: MediaQuery.of(context).size.width,
                        decoration: new BoxDecoration(
                            color: backgroundColor.withOpacity(0.3)),
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height / 4,
                        child: name == "Favoritas"
                            ? Image.asset("assets/images/Favs_cover.jpg")
                            : Image.asset("assets/images/defaultCover.png")),
                  ],
                ),
              ),
              // Lista el nombre de la playlist
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    shuffleButton(name, songs, context),
                  ],
                ),
              ),
              playlistsDivider(),
              ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: songs.isEmpty ? 0 : songs.length,
                itemBuilder: (BuildContext context, int index) {
                  return new GenericSongItem(songs[index]);
                },
              )
            ],
          ),
        ));
  }
}
