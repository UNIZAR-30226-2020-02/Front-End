import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playstack/services/database.dart';
import 'package:playstack/shared/common.dart';

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
            backgroundColor: Colors.transparent,
            leading: IconButton(
                icon: Icon(CupertinoIcons.back),
                onPressed: () => Navigator.of(context).pop()),
          ),
          backgroundColor: Colors.transparent,
          body: ListView(
            children: <Widget>[
              // Lista el nombre de la playlist
              Center(
                child: Text(
                  name,
                  style: TextStyle(fontSize: 25, fontFamily: 'Circular'),
                ),
              ),

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
