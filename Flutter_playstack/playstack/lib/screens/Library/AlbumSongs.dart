import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playstack/models/Album.dart';
import 'package:playstack/shared/Loading.dart';
import 'package:playstack/shared/common.dart';
import 'package:playstack/services/database.dart';
import 'dart:ui' as ui;

class AlbumSongs extends StatefulWidget {
  final Album album;
  AlbumSongs(this.album);
  @override
  _AlbumSongsState createState() => _AlbumSongsState(album);
}

class _AlbumSongsState extends State<AlbumSongs> {
  _AlbumSongsState(this.album);

  bool _loading = true;
  List songs = new List();

  final Album album;

  @override
  void initState() {
    super.initState();

    _getAlbumSongs();
  }

  void _getAlbumSongs() async {
    songs = await getAlbumSongs(album.title);
    if (mounted)
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
              album.title,
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
                    Container(
                        height: MediaQuery.of(context).size.height / 3.8,
                        width: MediaQuery.of(context).size.width / 1.8,
                        child: Image.network(album.coverUrl)),
                    BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        height: MediaQuery.of(context).size.height / 3.8,
                        width: MediaQuery.of(context).size.width / 1.8,
                        decoration: new BoxDecoration(
                            color: backgroundColor.withOpacity(0.3)),
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height / 2.9,
                        width: MediaQuery.of(context).size.width / 1.9,
                        child: Image.network(album.coverUrl))
                  ],
                ),
              ),
              // Lista el nombre de la playlist
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 5),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      shuffleButton(album.title, songs, context),
                    ],
                  ),
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
                        return new SongItem(
                          songs[index],
                          songs,
                          album.title,
                          isNotOwn: true,
                        );
                      },
                    )
            ],
          ),
        ));
  }
}
