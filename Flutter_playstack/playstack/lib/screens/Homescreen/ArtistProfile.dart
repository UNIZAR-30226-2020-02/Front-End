import 'package:flutter/material.dart';
import 'package:playstack/models/Artist.dart';
import 'package:playstack/shared/Loading.dart';
import 'package:playstack/services/database.dart';
import 'package:playstack/shared/common.dart';

class ArtistProfile extends StatefulWidget {
  final Artist artist;

  ArtistProfile(this.artist);
  @override
  _ArtistProfileState createState() => _ArtistProfileState(artist);
}

class _ArtistProfileState extends State<ArtistProfile> {
  final Artist artist;
  bool _loading = true;

  List songs = new List();

  _ArtistProfileState(this.artist);

  @override
  void initState() {
    super.initState();
    _getArtistSongs();
  }

  void _getArtistSongs() async {
    songs = await getArtistSongsDB(artist.name);
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Color.fromRGBO(80, 20, 20, 4.0),
                Color(0xFF191414),
              ], begin: Alignment.topLeft, end: FractionalOffset(0.3, 0.3)),
            ),
            child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  centerTitle: true,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  title: Text(artist.name),
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0),
                  ),
                ),
                backgroundColor: Colors.transparent,
                body: ListView(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Center(
                        child: Column(
                      children: <Widget>[
                        SizedBox(height: 10),
                        CircleAvatar(
                            radius: 60,
                            backgroundImage: NetworkImage(artist.photo)),
                      ],
                    )),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                          child: Text(
                            "Canciones de " + artist.name,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: songs.isEmpty ? 0 : songs.length,
                          itemBuilder: (BuildContext context, int index) {
                            return new SongItem(
                              songs[index],
                              songs,
                              artist.name,
                              isNotOwn: true,
                            );
                          },
                        )
                      ],
                    ),
                  )
                ])));
  }
}
