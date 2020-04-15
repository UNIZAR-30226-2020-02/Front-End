import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  bool _loading = true;

  List songs = new List();

  _GenresSongsState(this.genre);

  @override
  void initState() {
    super.initState();
    print("Se van a cargar las canciones de $genre");
    getSongsByGenre(genre);
  }

  Future<void> getSongsByGenre(String genre) async {
    print("Recopilando genero $genre...");
    //get/song/bygenre?NombreGenero
    dynamic response = await http.get(
      "https://playstack.azurewebsites.net/get/song/bygenre?NombreGenero=$genre",
      headers: {"Content-Type": "application/json"},
    );
    print("Statuscode " + response.statusCode.toString());
    //print("Body:" + response.body.toString());
    if (response.statusCode == 200) {
      response = jsonDecode(response.body);
      response
          .forEach((x, song) => print(x.toString() + " y " + song.toString()));
      /* for (final s in response) {
        var song = s;
        print("Cancion " + song.toString());
      } */
      setState(() {
        _loading = false;
      });
    } else {
      print(response.body);
    }
  }

  Widget _buildList() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: songs.isEmpty ? 0 : songs.length,
      itemBuilder: (BuildContext context, int index) {
        return new SongItem(
            songs[index]['title'], songs[index]['artist'], martinGarrix);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : Container(
            child: Center(child: Text('data')),
          );
  }
}
