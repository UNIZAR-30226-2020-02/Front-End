import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playstack/models/Audio.dart';
import 'package:playstack/models/Song.dart';
import 'package:playstack/shared/Loading.dart';
import 'dart:ui' as ui;
import 'package:playstack/services/database.dart';

import 'package:playstack/shared/common.dart';

var martinGarrix =
    'https://c1.staticflickr.com/2/1841/44200429922_d0cbbf22ba_b.jpg';

class GenresSongs extends StatefulWidget {
  GenresSongs({
    Key key,
  }) : super(key: key);
  @override
  _GenresSongsState createState() => _GenresSongsState();
}

class _GenresSongsState extends State<GenresSongs> {
  bool _loading = true;
  List<Song> songsInGenre = new List();

  @override
  void initState() {
    super.initState();
    _getSongs();
  }

  void _getSongs() async {
    songsInGenre = await getSongsByGenre(currentGenre.name);
    if (mounted)
      setState(() {
        _loading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => homeIndex.value = previousIndex),
        centerTitle: true,
        title: Text(currentGenre.name,
            style: TextStyle(
                fontFamily: 'Circular',
                fontSize: MediaQuery.of(context).size.width / 18)),
      ),
      backgroundColor: backgroundColor,
      body: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: songsInGenre.isEmpty ? 4 : songsInGenre.length + 3,
          itemBuilder: (BuildContext context, int index) {
            return index == 0
                ? Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Image.network(currentGenre.photoUrl),
                        BackdropFilter(
                          filter:
                              ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: Container(
                            height: MediaQuery.of(context).size.height / 3,
                            width: MediaQuery.of(context).size.width,
                            decoration: new BoxDecoration(
                                color: backgroundColor.withOpacity(0.3)),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 4,
                            child: Image.network(currentGenre.photoUrl)),
                      ],
                    ),
                  )
                : index == 1
                    ? Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            shuffleButton(
                                currentGenre.name, songsInGenre, context),
                          ],
                        ),
                      )
                    : index == 2
                        ? playlistsDivider()
                        : _loading
                            ? LoadingSongs()
                            : new SongItem(
                                songsInGenre[index - 3],
                                songsInGenre,
                                currentGenre.name,
                                isNotOwn: false,
                              );
          }),
    );
  }
}
