import 'package:flutter/material.dart';
import 'package:playstack/models/Genre.dart';
import 'package:playstack/screens/Homescreen/HomeScreenElements.dart';
import 'package:playstack/screens/Library/Playlist.dart';
import 'package:playstack/screens/Library/Podcasts.dart';
import 'package:playstack/screens/Search/SearchProcess.dart';
import 'package:playstack/services/database.dart';
import 'package:playstack/shared/Loading.dart';
import 'package:playstack/shared/common.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List yourPlaylists = new List();
  List<Genre> genresList = new List();

  bool _loadingGenres = true;
  bool _loadingLastSongs = true;
  bool _loadingYourPlaylists = true;

  @override
  void initState() {
    super.initState();
    getLastSongs();
    getYourPlaylists();
  }

  void getLastSongs() async {
    recentlyPlayedPodcasts.clear();
    recentlyPlayedSongs.clear();
    await getLastSongsListenedToDB(userName);
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

  Widget searchScreen() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(10, 20, 15, 0),
        child: ListView(children: <Widget>[
          Text(
            'Search',
            style: TextStyle(fontFamily: 'Circular', fontSize: 25),
          ),
          _searchBar(context),
          yourPlaylistsList(),
          recentlyPlayedSongsList(),
          recentlyPlayedPodcastsList()
        ]));
  }

  Widget showSearch(int index) {
    Widget result;
    switch (index) {
      case 0:
        result = searchScreen();
        break;
      case 1:
        result = SearchProcess();
        break;
      case 2:
        result = PodcastEpisodes(podcast: currentPodcast);
        break;
      case 3:
        result = Playlist(currentPlaylist);
        break;
    }
    return result;
  }

  Widget defSearchScreen() {
    return Scaffold(
      backgroundColor: Color(0xFF191414),
      body: ValueListenableBuilder(
        builder: (BuildContext context, value, Widget child) {
          return showSearch(searchIndex.value);
        },
        valueListenable: searchIndex,
      ),
    );
  }

  Widget _searchBar(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
            child: FlatButton(
                color: Colors.white,
                onPressed: () => searchIndex.value = 1, // SearchProcess,
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

  Widget recentlyPlayedPodcastsList() {
    var size = MediaQuery.of(context).size;
    return _loadingLastSongs
        ? Center(child: LoadingOthers())
        : Padding(
            padding: const EdgeInsets.only(top: 5, left: 5, bottom: 5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    "Podcasts reproducidos recientemente",
                    style: TextStyle(fontFamily: 'Circular', fontSize: 25),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height / 5,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: recentlyPlayedPodcasts.isEmpty
                        ? 0
                        : recentlyPlayedPodcasts.length,
                    itemBuilder: (BuildContext context, int index) {
                      return PodcastItem(recentlyPlayedPodcasts[index],
                          size.width, size.height);
                    },
                  ),
                )
              ],
            ),
          );
  }

  Widget recentlyPlayedSongsList() {
    return _loadingLastSongs
        ? Center(child: LoadingOthers())
        : Padding(
            padding: const EdgeInsets.only(top: 5, left: 5, bottom: 5.0),
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
                  height: MediaQuery.of(context).size.height / 5,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: recentlyPlayedSongs.isEmpty
                        ? 0
                        : recentlyPlayedSongs.length,
                    itemBuilder: (BuildContext context, int index) {
                      return SongTile(
                          song: recentlyPlayedSongs[index],
                          songsList: recentlyPlayedSongs,
                          songsListName: "Reproducidas recientemente");
                    },
                  ),
                )
              ],
            ),
          );
  }

  Widget yourPlaylistsList() {
    return _loadingYourPlaylists
        ? Center(child: LoadingOthers())
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
                        onTap: () {
                          currentPlaylist = yourPlaylists[index];
                          searchIndex.value = 3;
                        },
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
