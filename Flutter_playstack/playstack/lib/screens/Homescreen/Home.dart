import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playstack/models/Genre.dart';
import 'package:playstack/screens/GenresSongs.dart';
import 'package:playstack/screens/Homescreen/HomeScreenElements.dart';
import 'package:playstack/screens/Homescreen/PublicProfile.dart';
import 'package:playstack/screens/Homescreen/Settings.dart';
import 'package:playstack/screens/Homescreen/Social/SearchPeople.dart';
import 'package:playstack/screens/Homescreen/Social/Social.dart';
import 'package:playstack/screens/Library/ArtistSongs.dart';
import 'package:playstack/screens/Library/Playlist.dart';
import 'package:playstack/services/database.dart';
import 'package:playstack/shared/Loading.dart';
import 'package:playstack/shared/common.dart';
import 'package:playstack/screens/Library/Podcasts.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List artistsList = new List();
  List podcastsList = new List();
  List<Genre> genresList = new List();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() async {
    podcastsList = await getAllPodcastsDB();
    artistsList = await getAllArtistsDB();
    genresList = await getAllGenres(onlyFirtstFour: false);
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
                  artistsList[index].title, artistsList[index].photo);
            },
          ),
        )
      ],
    );
  }

  Widget recommendedPodcasts() {
    var size = MediaQuery.of(context).size;
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
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              itemCount: podcastsList.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                return PodcastItem(
                    podcastsList[index], size.width, size.height);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget genres() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 15.0),
          Text(
            'Géneros que te pueden gustar',
            style: TextStyle(fontFamily: 'Circular', fontSize: 22.0),
          ),
          SizedBox(height: 16.0),
          Row(
            children: <Widget>[
              ItemCard(genresList.elementAt(0)),
              SizedBox(
                width: 16.0,
              ),
              ItemCard(genresList.elementAt(1)),
            ],
          ),
          SizedBox(
            height: 32.0,
          ),
          Row(
            children: <Widget>[
              ItemCard(genresList.elementAt(2)),
              SizedBox(
                width: 16.0,
              ),
              ItemCard(genresList.elementAt(3)),
            ],
          ),
          SizedBox(
            height: 32.0,
          ),
        ],
      ),
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
                          allGenres(),
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
        result = GenresSongs();
        break;
      case 4:
        result = ArtistsSongs(currentArtist, currentArtistImage);
        break;
      case 5:
        result = Playlist(
          currentPlaylist,
          isNotOwn: currentPlaylistInNotOwn,
        );
        break;
      case 6:
        result = YourPublicProfile();
        break;
      case 7:
        result = SearchPeople();
        break;
      case 8:
        result = PodcastEpisodes(podcast: currentPodcast);
        break;
    }
    return result;
  }

  Widget allGenres() {
    return Column(
      children: <Widget>[
        Text(
          "Géneros",
          style: TextStyle(fontFamily: 'Circular', fontSize: 25),
        ),
        Container(
          child: GridView.count(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              // crossAxisCount is the number of columns
              crossAxisCount: 2,
              // This creates two columns with two items in each column
              children: new List<Widget>.generate(
                genresList.length,
                (index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: new GridTile(
                        child: Flex(
                      children: <Widget>[ItemCard(genresList[index])],
                      direction: Axis.vertical,
                    )),
                  );
                },
              )),
        ),
      ],
    );
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
