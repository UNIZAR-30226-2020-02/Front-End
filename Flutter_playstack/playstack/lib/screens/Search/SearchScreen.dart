import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:playstack/services/database.dart';
import 'package:playstack/shared/common.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
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
            yourPlaylists()
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
                        'Artists, songs or Podcasts',
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
    return Padding(
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
            child: FutureBuilder(
                future: getLastSongsListenedToDB(userName),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List recentlyPlayedSongs = snapshot.data;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: recentlyPlayedSongs.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: <Widget>[
                            SizedBox(
                              height: MediaQuery.of(context).size.height / 8,
                              width: MediaQuery.of(context).size.width / 3,
                              child: Image.network(
                                recentlyPlayedSongs[index]
                                    .albumCoverUrls
                                    .elementAt(0),
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                            Padding(padding: EdgeInsets.all(5.0)),
                            Text(
                              recentlyPlayedSongs[index].title,
                              style: TextStyle(
                                color: Colors.white.withOpacity(1.0),
                                fontSize: 15.0,
                              ),
                            )
                          ],
                        );
                      },
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                }),
          ),
        ],
      ),
    );
  }
  //    playlists = await getUserPlaylists();

  Widget yourPlaylists() {
    return Padding(
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
            child: FutureBuilder(
                future: getUserPlaylists(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List _userPlaylists = snapshot.data;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: _userPlaylists.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: MediaQuery.of(context).size.height / 8,
                                width: MediaQuery.of(context).size.width / 3,
                                child: playListCover(
                                    _userPlaylists[index].coverUrls),
                              ),
                              Padding(padding: EdgeInsets.all(5.0)),
                              Text(
                                _userPlaylists[index].name,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(1.0),
                                  fontSize: 15.0,
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                }),
          ),
        ],
      ),
    );
  }
}
