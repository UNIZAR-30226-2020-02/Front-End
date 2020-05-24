import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playstack/shared/Loading.dart';
import 'package:playstack/shared/common.dart';
import 'package:playstack/services/database.dart';
import 'dart:ui' as ui;

class ArtistsSongs extends StatefulWidget {
  final String artistName;
  final String artistPhoto;
  ArtistsSongs(this.artistName, this.artistPhoto);
  @override
  _ArtistsSongsState createState() =>
      _ArtistsSongsState(artistName, artistPhoto);
}

class _ArtistsSongsState extends State<ArtistsSongs> {
  _ArtistsSongsState(this.artistName, this.artistPhoto);

  bool _loading = true;
  List songs = new List();

  final String artistName;
  final String artistPhoto;

  @override
  void initState() {
    super.initState();

    _getArtistSongs();
  }

  void _getArtistSongs() async {
    songs = await getArtistSongsDB(artistName);
    if (mounted)
      setState(() {
        _loading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    List artistPhotoList = new List();
    artistPhotoList.add(artistPhoto);
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
              artistName,
              style: TextStyle(fontSize: 25, fontFamily: 'Circular'),
            ),
            backgroundColor: Colors.transparent,
            leading: IconButton(
                icon: Icon(CupertinoIcons.back),
                onPressed: () => homeIndex.value = 0),
          ),
          backgroundColor: Colors.transparent,
          body: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    SizedBox(
                        height: MediaQuery.of(context).size.height / 4,
                        width: MediaQuery.of(context).size.width / 2,
                        child: playListCover(artistPhotoList)),
                    BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        height: MediaQuery.of(context).size.height / 4,
                        width: MediaQuery.of(context).size.width,
                        decoration: new BoxDecoration(
                            color: backgroundColor.withOpacity(0.3)),
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height / 4,
                        width: MediaQuery.of(context).size.width / 2,
                        child: playListCover(artistPhotoList)),
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
                      shuffleButton(artistName, songs, context),
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
                          artistName,
                          isNotOwn: true,
                        );
                      },
                    )
            ],
          ),
        ));
  }
}
