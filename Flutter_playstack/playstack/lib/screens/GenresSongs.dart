import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:playstack/models/Song.dart';
import 'package:playstack/screens/Homescreen/Home.dart';
import 'package:playstack/shared/Loading.dart';
import 'dart:convert';

import 'package:playstack/shared/common.dart';

var martinGarrix =
    'https://c1.staticflickr.com/2/1841/44200429922_d0cbbf22ba_b.jpg';

class GenresSongs extends StatefulWidget {
  final genre;

  GenresSongs({
    Key key,
    @required this.genre,
  }) : super(key: key);
  @override
  _GenresSongsState createState() => _GenresSongsState(genre);
}

class _GenresSongsState extends State<GenresSongs> {
  String genre;

  List<Song> songs = new List();

  _GenresSongsState(this.genre);

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
      setState(() {});
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
        return new SongItem(songs[index], songs, genre);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title:
            Text(genre, style: TextStyle(fontFamily: 'Circular', fontSize: 25)),
      ),
      backgroundColor: backgroundColor,
      body: ListView(
        children: <Widget>[_buildList()],
      ),
      bottomNavigationBar: SizedBox(
        height: MediaQuery.of(context).size.height / 9,
        child: BottomNavigationBar(
            fixedColor: Colors.red[600],
            currentIndex: currentIndex,
            onTap: (int index) {
              currentIndex = index;
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => mainScreens[index]));
            },
            type: BottomNavigationBarType.shifting,
            items: [
              BottomNavigationBarItem(
                  icon: new Icon(
                    CupertinoIcons.home,
                    size: 25,
                  ),
                  title: new Text(
                    "Home",
                    style: TextStyle(fontSize: 10),
                  )),
              BottomNavigationBarItem(
                  icon: new Icon(CupertinoIcons.search, size: 25),
                  title: new Text(
                    "Search",
                    style: TextStyle(fontSize: 10),
                  )),
              BottomNavigationBarItem(
                  icon: new Icon(CupertinoIcons.collections, size: 25),
                  title: new Text(
                    "Library",
                    style: TextStyle(fontSize: 10),
                  )),
              BottomNavigationBarItem(
                  icon: new Icon(CupertinoIcons.music_note),
                  title: new Text("Play", style: TextStyle(fontSize: 10))),
            ]),
      ),
    );
  }
}
