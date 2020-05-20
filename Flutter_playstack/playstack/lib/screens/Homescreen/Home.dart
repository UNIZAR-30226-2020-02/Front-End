import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playstack/screens/GenresSongs.dart';
import 'package:playstack/screens/Homescreen/HomeScreenElements.dart';
import 'package:playstack/screens/Homescreen/Settings.dart';
import 'package:playstack/screens/Homescreen/Social/Social.dart';
import 'package:playstack/screens/Library/ArtistSongs.dart';
import 'package:playstack/services/database.dart';
import 'package:playstack/shared/Loading.dart';
import 'package:playstack/shared/common.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List artistsList = new List();
  List podcastsList = new List();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() async {
    podcastsList = await getAllPodcastsDB();
    artistsList = await getAllArtistsDB();
    if (mounted)
      setState(() {
        _loading = false;
      });
  }

  Widget artistsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
          child: Text(
            "Artistas",
            style: TextStyle(fontFamily: 'Circular', fontSize: 22),
          ),
        ),
        Container(
          height: 165.0,
          child: ListView.builder(
            itemCount: artistsList.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              return ArtistItem(
                  artistsList[index].name, artistsList[index].photo);
            },
          ),
        )
      ],
    );
  }

  Widget recommendedPodcasts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            "Podcasts Recomendados",
            style: TextStyle(fontFamily: 'Circular', fontSize: 22.0),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 0),
          child: Container(
            height: MediaQuery.of(context).size.height / 4,
            width: MediaQuery.of(context).size.height / 3,
            child: ListView.builder(
              itemCount: podcastsList.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                return PodcastItem(podcastsList[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget startHome() {
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
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent,
                  centerTitle: true,
                  leading: IconButton(
                    icon: Icon(CupertinoIcons.group_solid),
                    onPressed: () {
                      homeIndex.value = 1;
                    },
                  ),
                  title: Container(
                      height: 40,
                      width: 40,
                      child: Image.asset('lib/assets/Photos/logo.png')),
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0),
                  ),
                  actions: <Widget>[
                    IconButton(
                        icon: Icon(CupertinoIcons.settings),
                        onPressed: () => homeIndex.value = 2)
                  ],
                ),
                backgroundColor: Colors.transparent,
                body: ListView(
                  children: <Widget>[
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          artistsCards(),
                          genres(),
                          recommendedPodcasts()
                        ],
                      ),
                    )
                  ],
                )));
  }

  Widget showHome(int index) {
    Widget result;
    switch (index) {
      case 0:
        result = startHome();
        break;
      case 1:
        result = Social();
        break;
      case 2:
        result = Settings();
        break;
      case 3:
        result = GenresSongs(genre: currentGenre, image: currentGenreImage);
        break;
      case 4:
        result = ArtistsSongs(currentArtist, currentArtistImage);
        break;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: homeIndex,
        builder: (BuildContext context, int value, Widget child) {
          return WillPopScope(
              onWillPop: () async {
                homeIndex.value = 0;
                return false;
              },
              child: showHome(homeIndex.value));
        });
  }
}
