import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:playstack/screens/Library/Playlist.dart';
import 'package:playstack/screens/Player/PlayerWidget.dart';
import 'package:playstack/screens/Player/PlayingNow.dart';
import 'package:playstack/services/database.dart';
import 'package:playstack/shared/Loading.dart';
import 'package:playstack/shared/common.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List lastSongsListenedto = new List();
  List yourPlaylists = new List();

  bool _loadingLastSongs = true;
  bool _loadingYourPlaylists = true;

  @override
  void initState() {
    super.initState();
    getLastSongs();
    getYourPlaylists();
  }

  void getLastSongs() async {
    lastSongsListenedto = await getLastSongsListenedToDB(userName);
    if (mounted)
      setState(() {
        _loadingLastSongs = false;
      });
  }

  void getYourPlaylists() async {
    yourPlaylists = await getUserPlaylists();
    if (mounted)
      setState(() {
        _loadingYourPlaylists = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    return defSearchScreen();
  }

  Widget defSearchScreen() {
    return Scaffold(
      backgroundColor: Color(0xFF191414),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 20, 15, 0),
        child: ListView(
          children: <Widget>[
            Text(
              'Search',
              style: TextStyle(fontFamily: 'Circular', fontSize: 25),
            ),
            _searchBar(context),
            recentlyPlayedSongs(),
            yourPlaylistsList()
          ],
        ),
      ),
    );
  }

  Widget _searchBar(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
            child: FlatButton(
                color: Colors.white,
                onPressed: () =>
                    Navigator.of(context).pushNamed('searchProcessScreen'),
                child: SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.search,
                        color: Colors.black,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Buscar artistas,canciones,podcasts...',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      ),
                    ],
                  ),
                )))
      ],
    );
  }

  Widget recentlyPlayedSongs() {
    return _loadingLastSongs
        ? LoadingOthers()
        : Padding(
            padding: const EdgeInsets.only(top: 5, left: 5, bottom: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    "Reproducidas recientemente",
                    style: TextStyle(fontFamily: 'Circular', fontSize: 25),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height / 6,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: lastSongsListenedto.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          setQueue(
                              lastSongsListenedto,
                              lastSongsListenedto[index],
                              "Reproducidas recientemente");
                          onPlayerScreen = true;
                          if (player == null) player = PlayerWidget();
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  PlayingNowScreen()));
                        },
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: MediaQuery.of(context).size.height / 8,
                              width: MediaQuery.of(context).size.width / 3,
                              child: Image.network(
                                lastSongsListenedto[index]
                                    .albumCoverUrls
                                    .elementAt(0),
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                            Padding(padding: EdgeInsets.all(5.0)),
                            Text(
                              lastSongsListenedto[index].title,
                              style: TextStyle(
                                color: Colors.white.withOpacity(1.0),
                                fontSize: 15.0,
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          );
  }

  Widget yourPlaylistsList() {
    return _loadingYourPlaylists
        ? LoadingOthers()
        : Padding(
            padding: const EdgeInsets.only(top: 5, left: 5, bottom: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    "Hechas por ti",
                    style: TextStyle(fontFamily: 'Circular', fontSize: 25),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height / 6,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: yourPlaylists.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    Playlist(yourPlaylists[index]))),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: MediaQuery.of(context).size.height / 8,
                                width: MediaQuery.of(context).size.width / 3,
                                child: playListCover(
                                    yourPlaylists[index].coverUrls),
                              ),
                              Padding(padding: EdgeInsets.all(5.0)),
                              Text(
                                yourPlaylists[index].title,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(1.0),
                                  fontSize: 15.0,
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          );
  }
}
