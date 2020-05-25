import 'package:flutter/material.dart';
import 'package:playstack/models/Album.dart';
import 'package:playstack/models/Artist.dart';
import 'package:playstack/models/Audio.dart';
import 'package:playstack/models/Song.dart';
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

  List<Audio> songs = new List();
  List albums = new List();

  _ArtistProfileState(this.artist);

  @override
  void initState() {
    super.initState();
    _getArtisAlbums();
  }

  void _getArtisAlbums() async {
    songs = await getArtistSongsDB(artist.title);
    albums = await getArtistAlbumsDB(artist.title);
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
                      if (currentIndex.value == 1) //Search
                        searchIndex.value = 1;
                      else //Library
                        musicIndex.value = 0;
                    },
                  ),
                  title: Text(artist.title),
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
                            radius: 70,
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
                            "Canciones de " + artist.title,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        songs.isEmpty
                            ? Container(
                                height: MediaQuery.of(context).size.height / 5,
                                width: MediaQuery.of(context).size.width,
                                child: Center(
                                    child: Text(
                                        "No hay canciones de este artista",
                                        style: TextStyle(
                                            color: Colors.grey[600]))),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: songs.isEmpty ? 0 : songs.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return new SongItem(
                                    songs[index],
                                    songs,
                                    artist.title,
                                    isNotOwn: true,
                                  );
                                },
                              ),
                        albums.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text("Álbumes de " + artist.title,
                                    style: TextStyle(fontSize: 20)),
                              )
                            : Text(""),
                        albums.isNotEmpty
                            ? ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: albums.isEmpty ? 0 : albums.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return new AlbumTile(albums[index]);
                                },
                              )
                            : Text("")
                      ],
                    ),
                  )
                ])));
  }
}
