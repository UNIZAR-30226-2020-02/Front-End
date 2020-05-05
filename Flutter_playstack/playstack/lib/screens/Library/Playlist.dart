import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:playstack/models/PlaylistType.dart';
import 'package:playstack/services/database.dart';
import 'package:playstack/shared/Loading.dart';
import 'package:playstack/shared/common.dart';
import 'dart:ui' as ui;

class Playlist extends StatefulWidget {
  final PlaylistType playlist;
  Playlist(this.playlist);

  @override
  _PlaylistState createState() => _PlaylistState(playlist);
}

class _PlaylistState extends State<Playlist> {
  final PlaylistType playlist;

  List songs = new List();
  bool _loading = true;

  _PlaylistState(this.playlist);

  @override
  void initState() {
    super.initState();
    getSongs();
  }

  void getSongs() async {
    if (playlist.name == "Favoritas") {
      songs = await getFavoriteSongs();
    } else {
      songs = await getPlaylistSongsDB(playlist.name);
    }
    setState(() {
      _loading = false;
    });
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
              playlist.name,
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
                    playlist.name == "Favoritas"
                        ? Image.asset("assets/images/Favs_cover.jpg")
                        : playListCover(playlist.coverUrls),
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
                        child: playlist.name == "Favoritas"
                            ? Image.asset("assets/images/Favs_cover.jpg")
                            : playListCover(playlist.coverUrls)),
                  ],
                ),
              ),
              // Lista el nombre de la playlist
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    shuffleButton(playlist.name, songs, context),
                  ],
                ),
              ),
              playlistsDivider(),
              _loading
                  ? LoadingSongs()
                  : ListView.builder(
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
