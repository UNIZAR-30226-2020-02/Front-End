import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:playstack/models/Audio.dart';
import 'package:playstack/models/Song.dart';
import 'package:playstack/shared/Loading.dart';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:playstack/shared/common.dart';

var martinGarrix =
    'https://c1.staticflickr.com/2/1841/44200429922_d0cbbf22ba_b.jpg';

class GenresSongs extends StatefulWidget {
  final genre;
  final image;
  GenresSongs({Key key, @required this.genre, @required this.image})
      : super(key: key);
  @override
  _GenresSongsState createState() => _GenresSongsState(genre, image);
}

class _GenresSongsState extends State<GenresSongs> {
  String genre;
  var image;
  bool _loading = true;

  List<Audio> songs = new List();

  _GenresSongsState(this.genre, this.image);

  @override
  void initState() {
    super.initState();
    print("Se van a cargar las canciones de $genre");
    getSongsByGenre(genre);
  }

  void addSong(String title, List artists, String url, List albunes,
      dynamic urlAlbums, bool isFavorite) {
    if (urlAlbums is String) {
      urlAlbums = urlAlbums.toList();
    }
    Song newSong = new Song(
        title: title,
        artists: artists,
        url: url,
        albums: albunes,
        albumCoverUrls: urlAlbums,
        isFav: isFavorite);

    songs.add(newSong);
  }

  Future<void> getSongsByGenre(String genre) async {
    print("Recopilando genero $genre...");
    print("Con usuario " + userName);
    dynamic response = await http.get(
      "https://playstack.azurewebsites.net/get/song/bygenre?NombreGenero=$genre&Usuario=$userName",
      headers: {"Content-Type": "application/json"},
    );
    print("Statuscode " + response.statusCode.toString());
    //print("Body:" + response.body.toString());
    if (response.statusCode == 200) {
      response = jsonDecode(response.body);
      //response.forEach((title, info) => print(title + info.toString()));
      response.forEach((title, info) => addSong(
          title,
          info['Artistas'],
          info['url'],
          info['Albumes'],
          info['ImagenesAlbum'],
          info['EsFavorita']));
      setState(() {
        _loading = false;
      });
    } else {
      print(response.body);
    }
    print("Hay " + songs.length.toString() + " canciones de este genero");
  }

  Widget _buildList() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: songs.isEmpty ? 0 : songs.length,
      itemBuilder: (BuildContext context, int index) {
        return new SongItem(
          songs[index],
          songs,
          genre,
          isNotOwn: false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => homeIndex.value = 0),
        centerTitle: true,
        title: Text(genre,
            style: TextStyle(
                fontFamily: 'Circular',
                fontSize: MediaQuery.of(context).size.width / 18)),
      ),
      backgroundColor: backgroundColor,
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Image.asset(image),
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
                    child: Image.asset(image)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                shuffleButton(genre, songs, context),
              ],
            ),
          ),
          playlistsDivider(),
          _loading ? LoadingSongs() : _buildList()
        ],
      ),
    );
  }
}
