import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playstack/models/Artist.dart';
import 'package:playstack/models/Episode.dart';
import 'package:playstack/models/Podcast.dart';
import 'package:playstack/screens/Library/Language.dart';
import 'package:playstack/services/database.dart';
import 'package:playstack/shared/Loading.dart';
import 'package:playstack/shared/common.dart';

final int asciiCodeA = 'A'.codeUnitAt(0);
final int asciiCodeZ = 'Z'.codeUnitAt(0);
final int asciiCodea = 'a'.codeUnitAt(0);
final int asciiCodez = 'z'.codeUnitAt(0);

/*
List<String> imageurl = [
  'assets/images/Artists/Macklemore.jpg',
  'assets/images/Artists/Eminem.jpg',
  'assets/images/Artists/datweekaz.jpg',
  'assets/images/Artists/timmytrumpet.jpg'
];
List<String> artists = ['Macklemore', 'Eminem', 'Da Tweekaz', 'Timmy Trumpet'];

List collaboratorsExample() {
  List<Artist> exampleList = List<Artist>();
  for (int i = 0; i < artists.length; i++) {
    exampleList.add(Artist(artists[i], imageurl[i]));
  }
  return exampleList;
}

List episodesExample() {
  List<Episode> exampleList = List<Episode>();
  exampleList.add(Episode(
      title: "Episode1",
      albumCoverUrls: [
        "https://playstack.azurewebsites.net/media/images/Rap_God_cover_Q1ZkqkT.jpg"
      ],
      topics: null,
      artists: ["Josefina", "MariCarmen"],
      url:
          "https://playstack.azurewebsites.net/media/audio/Vicetone___Tony_Igy_-_Astronomia.mp3",
      duration: 5,
      date: "20/20/20"));
  exampleList.add(Episode(
      title: "Episode2",
      albumCoverUrls: [
        "https://playstack.azurewebsites.net/media/images/Macklemore-y-Ryan-Lewis-The-heist-44118_front_AnIqR2Y.jpg"
      ],
      topics: null,
      artists: ["Josefina", "MariCarmen"],
      url:
          "https://playstack.azurewebsites.net/media/audio/Vicetone___Tony_Igy_-_Astronomia.mp3",
      duration: 15,
      date: "7/3/20"));
  return exampleList;
}

List getExampleList() {
  List<Podcast> exampleList = List<Podcast>();
  exampleList.add(Podcast(
      title: "Example1",
      coverUrl: 'lib/assets/Photos/logo.png',
      hosts: [collaboratorsList.elementAt(0)],
      episodes: episodesExample(),
      url: "",
      desc:
          'Lorem ipsum es el texto que se usa habitualmente en diseño gráfico en demostraciones de tipografías o de borradores de diseño para probar el diseño visual antes de insertar el texto final. Aunque no posee actualmente fuentes para justificar sus hipótesis, el profesor de filología clásica Richard McClintock asegura que su uso se remonta a los impresores de comienzos del siglo XVI.1​ Su uso en algunos editores de texto muy conocidos en la actualidad ha dado al texto lorem ipsum nueva popularidad. El texto en sí no tiene sentido, aunque no es completamente aleatorio, sino que deriva de un texto de Cicerón en lengua latina, a cuyas palabras se les han eliminado sílabas o letras. El significado del texto no tiene importancia, ya que solo es una demostración o prueba, pero se inspira en la obra de Cicerón De finibus bonorum et malorum (Sobre los límites del bien y del mal) que comienza con:',
      language: Language('es'),
      topics: null));
  exampleList.add(Podcast(
      title: "Example2",
      coverUrl: 'lib/assets/Photos/logo.png',
      hosts: null,
      episodes: List(),
      url: "",
      desc:
          'a b c d e f g h i j k l m n o p q r s t u v w x y z 1 2 3 4 5 6 7 8 9 0 ç ñ  : a b c d e f g h i j k l m n o p q r s t u v w x y z 1 2 3 4 5 6 7 8 9 0 ç ñ  : a b c d e f g h i j k l m n o p q r s t u v w x y z 1 2 3 4 5 6 7 8 9 0 ç ñ  : a b c d e f g h i j k l m n o p q r s t u v w x y z 1 2 3 4 5 6 7 8 9 0 ç ñ  :',
      language: Language('cn'),
      topics: null));
  return exampleList;
}
*/

void setPodcastQueue(String podcastName, List episodes, int currentIndex) {
  List tmpList = new List();
  List tmpList2 = new List();
  tmpList.addAll(episodes);
  for (int i = 0; i < currentIndex; i++) {
    tmpList2.add(tmpList.elementAt(i));
    tmpList.removeAt(i);
  }
  tmpList.removeAt(currentIndex);
  songsNextUpName = podcastName;
  currentAudio = episodes[currentIndex];
  songsNextUp = tmpList;
  songsPlayed = tmpList2;
  print("Tocada se marcara como escuchada");
  currentAudio.markAsListened();
}

Color colorFromName(String name) {
  int brightestColorAllowed = 0x00ff4a4a;
  int acum = 0;
  int max = name.length * asciiCodez;
  int asciiCode = 0;
  for (int i = 0; i < name.length; i++) {
    asciiCode = name.codeUnitAt(i);
    if (asciiCode >= asciiCodeA && asciiCode <= asciiCodeZ) {
      acum += asciiCodea - asciiCodeA;
    }
    if (asciiCode > asciiCodez) {
      acum += asciiCodez;
    } else {
      acum += asciiCode;
    }
  }
  return Color(((acum / max) * brightestColorAllowed).round() + 0xFF000000);
}

Widget topicButton(topic, width, height) {
  return Container(
    width: width * 0.6,
    height: height / 10,
    color: colorFromName(topic),
    child: Center(
        child: Text(topic,
            textAlign: TextAlign.center,
            style:
                TextStyle(fontSize: width / 20, fontWeight: FontWeight.w500))),
  );
}

Widget noPodcastsFoundWidget(int type, double width, double height) {
  return Padding(
    padding:
        EdgeInsets.fromLTRB(width / 20, height / 20, width / 20, height / 20),
    child: Column(
      children: <Widget>[
        Text(
            type != 2
                ? languageStrings['noPodcasts1']
                : languageStrings['noPodcasts4'],
            style:
                TextStyle(fontSize: width / 15, fontWeight: FontWeight.w500)),
        Padding(
            padding: EdgeInsets.only(top: width / 20),
            child: Text(
                type == 0
                    ? languageStrings['noPodcasts2']
                    : type == 1
                        ? languageStrings['noPodcasts3']
                        : languageStrings['noPodcasts5'],
                style: TextStyle(
                    fontSize: width / 25, fontWeight: FontWeight.w500)))
      ],
    ),
  );
}

Widget podcastTile(width, height, Podcast podcast) {
  return GestureDetector(
      onTap: () {
        currentPodcast = podcast;
        podcastIndex.value = 1;
      },
      child: SizedBox(
          height: height / 3.5,
          width: width,
          child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(
                          width: 0.2, color: Colors.white.withOpacity(0.7)),
                      bottom: BorderSide(
                          width: 0.2, color: Colors.white.withOpacity(0.7)))),
              child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      width / 20, width / 20, width / 20, width / 20),
                  child: Column(children: <Widget>[
                    Expanded(
                        flex: 2,
                        child: Row(children: <Widget>[
                          ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                podcast.coverUrl,
                                fit: BoxFit.cover,
                              )),
                          Expanded(
                              flex: 3,
                              child: Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(width / 20, 0, 0, 0),
                                  child: Text(podcast.title,
                                      overflow: TextOverflow.fade,
                                      style: TextStyle(
                                          fontSize: width / 20,
                                          fontWeight: FontWeight.w500))))
                        ])),
                    Expanded(
                        flex: 4,
                        child: LayoutBuilder(builder: (context, constraints) {
                          String aux = "";
                          String descP1 = "";
                          String descP2 = "";
                          List<String> descList = podcast.desc.split(" ");
                          int i = 0;
                          bool exceeded = false;
                          while (i < descList.length && !exceeded) {
                            if (aux != "") aux += " ";
                            aux += descList[i];
                            var tp = TextPainter(
                                maxLines: 4,
                                textAlign: TextAlign.left,
                                textDirection: TextDirection.ltr,
                                text: TextSpan(
                                  text: aux,
                                  style: TextStyle(fontSize: width / 25),
                                ));
                            tp.layout(
                                maxWidth: width * 0.80, minWidth: width * 0.80);
                            exceeded = tp.didExceedMaxLines;
                            if (!exceeded) {
                              if (descP1 != "") descP1 += " ";
                              descP1 += descList[i];
                              i++;
                            }
                          }
                          while (i < descList.length) {
                            if (descP2 != "") descP2 += " ";
                            descP2 += descList[i];
                            i++;
                          }

                          return Column(children: <Widget>[
                            Container(
                                height: height * 0.125,
                                width: width * 0.95,
                                child: Text(descP1,
                                    textAlign: TextAlign.justify,
                                    maxLines: 4,
                                    style: TextStyle(
                                        fontSize: width / 25,
                                        color: Colors.white.withOpacity(0.7)))),
                            Expanded(
                                child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.only(
                                            right: width * 0.05),
                                        child: Text(descP2,
                                            textAlign: TextAlign.justify,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontSize: width / 25,
                                                color: Colors.white
                                                    .withOpacity(0.7))))),
                                podcast.language.showPodcastLanguage(context),
                              ],
                            ))
                          ]);
                        }))
                  ])))));
}

class FavPodcasts extends StatefulWidget {
  @override
  _FavPodcastsState createState() => _FavPodcastsState();
}

class _FavPodcastsState extends State<FavPodcasts> {
  bool _loading = true;
  List favPodcastList;

  void getFollowed() async {
    favPodcastList = await getFollowedPodcastsDB();
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getFollowed();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return _loading
        ? Loading()
        : favPodcastList.length > 0
            ? ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: favPodcastList.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, int index) {
                  return podcastTile(width, height, favPodcastList[index]);
                })
            : noPodcastsFoundWidget(0, width, height);
  }
}

class PodcastCollaborators extends StatefulWidget {
  @override
  _PodcastCollaboratorsState createState() => _PodcastCollaboratorsState();
}

class _PodcastCollaboratorsState extends State<PodcastCollaborators> {
  bool _loading = true;
  List collaboratorsList;

  void getCollaborators() async {
    collaboratorsList = await getCollaboratorsDB();
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getCollaborators();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return _loading
        ? Loading()
        : collaboratorsList.length > 0
            ? ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: collaboratorsList.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, int index) {
                  return GestureDetector(
                      onTap: () {
                        currentPodcaster = collaboratorsList[index];
                        podcastIndex.value = 2;
                      },
                      child: SizedBox(
                          height: height / 8.5,
                          width: width,
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border(
                                    top: BorderSide(
                                        width: 0.2,
                                        color: Colors.white.withOpacity(0.7)),
                                    bottom: BorderSide(
                                        width: 0.2,
                                        color: Colors.white.withOpacity(0.7)))),
                            child: Padding(
                                padding: EdgeInsets.fromLTRB(width / 20,
                                    width / 20, width / 20, width / 20),
                                child: Row(children: <Widget>[
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        collaboratorsList[index].photo,
                                        fit: BoxFit.cover,
                                      )),
                                  Expanded(
                                      flex: 4,
                                      child: Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              width / 10, 0, 0, 0),
                                          child: Text(
                                              collaboratorsList[index].title,
                                              style: TextStyle(
                                                  fontSize: width / 15,
                                                  fontWeight:
                                                      FontWeight.w500))))
                                ])),
                          )));
                })
            : noPodcastsFoundWidget(1, width, height);
  }
}

class TopicsTab extends StatefulWidget {
  @override
  _TopicsTabState createState() => _TopicsTabState();
}

class _TopicsTabState extends State<TopicsTab> {
  bool _loading = true;
  List topicList = new List();

  void getTopics() async {
    topicList = await getPodcastThemesDB();
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    getTopics();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return _loading
        ? Loading()
        : ListView.builder(
            itemCount: (topicList.length / 2).ceil(),
            scrollDirection: Axis.vertical,
            itemBuilder: (context, int index) {
              return Container(
                  width: width,
                  height: height / 7.5,
                  child: 2 * index + 1 < topicList.length
                      ? Row(
                          children: <Widget>[
                            Expanded(
                                child: Padding(
                                    padding: EdgeInsets.fromLTRB(width / 30,
                                        width / 60, width / 30, width / 60),
                                    child: GestureDetector(
                                      onTap: () {
                                        currentTopic = topicList[2 * index];
                                        podcastIndex.value = 3;
                                      },
                                      child: topicButton(
                                          topicList[2 * index], width, height),
                                    ))),
                            Expanded(
                                child: Padding(
                                    padding: EdgeInsets.fromLTRB(width / 30,
                                        width / 60, width / 30, width / 60),
                                    child: GestureDetector(
                                      onTap: () {
                                        currentTopic = topicList[2 * index + 1];
                                        podcastIndex.value = 3;
                                      },
                                      child: topicButton(
                                          topicList[2 * index + 1],
                                          width,
                                          height),
                                    )))
                          ],
                        )
                      : Padding(
                          padding: EdgeInsets.fromLTRB(
                              width / 30, width / 60, width / 30, width / 60),
                          child: GestureDetector(
                              onTap: () {
                                currentTopic = topicList[2 * index];
                                podcastIndex.value = 3;
                              },
                              child: topicButton(
                                  topicList[2 * index], width, height))));
            });
  }
}

class PodcastEpisodes extends StatefulWidget {
  final Podcast podcast;

  PodcastEpisodes({this.podcast});

  @override
  _PodcastEpisodesState createState() =>
      _PodcastEpisodesState(podcast: podcast);
}

class _PodcastEpisodesState extends State<PodcastEpisodes> {
  final Podcast podcast;
  bool _loading = true;
  List episodesList = new List();
  _PodcastEpisodesState({this.podcast});

  void getPodcastEpisodes() async {
    episodesList = await getPodcastEpisodesDB(podcast.title);
    if (mounted)
      setState(() {
        _loading = false;
      });
  }

  @override
  void initState() {
    super.initState();
    getPodcastEpisodes();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                if (currentIndex.value == 0)
                  homeIndex.value = 0;
                else if (currentIndex.value == 1)
                  searchIndex.value = 0;
                else
                  podcastIndex.value = 0;
              }),
          centerTitle: true,
          title: Text(podcast.title,
              style: TextStyle(
                  fontFamily: 'Circular',
                  fontSize: MediaQuery.of(context).size.width / 18)),
        ),
        body: WillPopScope(
            onWillPop: () async {
              if (currentIndex.value == 0)
                homeIndex.value = 0;
              else if (currentIndex.value == 1)
                searchIndex.value = 0;
              else
                podcastIndex.value = 0;
              return false;
            },
            child: _loading
                ? Loading()
                : episodesList.length > 0
                    ? ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: episodesList.length,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, int index) {
                          return GestureDetector(
                              onTap: () {
                                setPodcastQueue(
                                    podcast.title, episodesList, index);
                                onPlayerScreen = true;
                                currentIndex.value = 3;
                              },
                              child: SizedBox(
                                  height: height / 5,
                                  width: width,
                                  child: Container(
                                      decoration: BoxDecoration(
                                          border: Border(
                                              top: BorderSide(
                                                  width: 0.2,
                                                  color: Colors.white
                                                      .withOpacity(0.7)),
                                              bottom: BorderSide(
                                                  width: 0.2,
                                                  color: Colors.white
                                                      .withOpacity(0.7)))),
                                      child: Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              width / 20,
                                              width / 20,
                                              width / 20,
                                              width / 20),
                                          child: Row(children: <Widget>[
                                            Container(
                                                width: width / 5,
                                                height: width / 5,
                                                child: Stack(children: <Widget>[
                                                  Container(
                                                      width: width / 6,
                                                      child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          child: Image.network(
                                                            episodesList[index]
                                                                .albumCoverUrls
                                                                .elementAt(0),
                                                            fit: BoxFit.cover,
                                                          ))),
                                                  Align(
                                                      alignment:
                                                          Alignment.bottomRight,
                                                      child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  2.0),
                                                          child: Container(
                                                              width: width / 10,
                                                              height:
                                                                  width / 15,
                                                              color:
                                                                  Colors.white,
                                                              child: Text(
                                                                  episodesList[index]
                                                                      .number
                                                                      .toString(),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          width /
                                                                              20,
                                                                      color: Colors
                                                                          .black)))))
                                                ])),
                                            Expanded(
                                                child: Container(
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                  Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                          languageStrings[
                                                                  'released'] +
                                                              " " +
                                                              episodesList[
                                                                      index]
                                                                  .date,
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                              fontSize:
                                                                  width / 30,
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.7)))),
                                                  Expanded(
                                                      flex: 5,
                                                      child: Padding(
                                                          padding:
                                                              EdgeInsets
                                                                  .fromLTRB(
                                                                      width /
                                                                          20,
                                                                      0,
                                                                      0,
                                                                      0),
                                                          child: Text(
                                                              episodesList[
                                                                      index]
                                                                  .title,
                                                              overflow:
                                                                  TextOverflow
                                                                      .fade,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      width /
                                                                          25,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500)))),
                                                ])))
                                          ])))));
                        })
                    : noPodcastsFoundWidget(2, width, height)));
  }
}

class PodcasterFeaturedIn extends StatefulWidget {
  final Artist podcaster;
  PodcasterFeaturedIn({this.podcaster});
  @override
  _PodcasterFeaturedInState createState() =>
      _PodcasterFeaturedInState(podcaster: podcaster);
}

class _PodcasterFeaturedInState extends State<PodcasterFeaturedIn> {
  final Artist podcaster;
  List collPodcasts = new List();
  bool _loading = true;
  _PodcasterFeaturedInState({this.podcaster});

  void getPodcasts() async {
    collPodcasts = await getCollaboratorPodcastsDB(podcaster.title);
    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getPodcasts();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
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
                      podcastIndex.value = 0;
                    },
                  ),
                  title: Text(podcaster.title),
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0),
                  ),
                ),
                backgroundColor: Colors.transparent,
                body: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: collPodcasts.length + 2,
                    itemBuilder: (BuildContext context, int index) {
                      return index == 0
                          ? Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Center(
                                  child: Column(
                                children: <Widget>[
                                  SizedBox(height: 10),
                                  CircleAvatar(
                                      radius: 70,
                                      backgroundImage:
                                          NetworkImage(podcaster.photo)),
                                ],
                              )),
                            )
                          : index == 1
                              ? Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 20, 15, 0),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text("Aperece en " + podcaster.title,
                                        style: TextStyle(fontSize: 20)),
                                  ))
                              : podcastTile(
                                  width, height, collPodcasts[index - 2]);
                    })));
  }
}

class PodcastsOfTopic extends StatefulWidget {
  final String topic;
  PodcastsOfTopic({this.topic});
  @override
  _PodcastsOfTopicState createState() => _PodcastsOfTopicState(topic: topic);
}

class _PodcastsOfTopicState extends State<PodcastsOfTopic> {
  final String topic;
  List podcasts = new List();
  bool _loading = true;
  _PodcastsOfTopicState({this.topic});

  void getPodcasts() async {
    podcasts = await getPodcastsByTopicDB(topic);
    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getPodcasts();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
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
                      podcastIndex.value = 0;
                    },
                  ),
                  title: Text(topic),
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0),
                  ),
                ),
                backgroundColor: Colors.transparent,
                body: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: podcasts.length,
                    itemBuilder: (BuildContext context, int index) {
                      return podcastTile(width, height, podcasts[index]);
                    })));
  }
}

class PodcastsTab extends StatefulWidget {
  @override
  _PodcastsTabState createState() => _PodcastsTabState();
}

class _PodcastsTabState extends State<PodcastsTab> {
  Widget defaultPage() {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Color(0xFF191414),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            bottomOpacity: 1.0,
            actions: <Widget>[
              Expanded(
                child: TabBar(
                  indicatorColor: Colors.red[800],
                  tabs: <Widget>[
                    Tab(
                      child: Text(
                        languageStrings['favPodcasts'],
                        style: TextStyle(fontFamily: 'Circular', fontSize: 15),
                      ),
                    ),
                    Tab(
                      child: Text(
                        languageStrings['podcasters'],
                        style: TextStyle(fontFamily: 'Circular', fontSize: 15),
                      ),
                    ),
                    Tab(
                      child: Text(
                        languageStrings['topics'],
                        style: TextStyle(fontFamily: 'Circular', fontSize: 15),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          body: TabBarView(
            children: <Widget>[
              FavPodcasts(),
              PodcastCollaborators(),
              TopicsTab()
            ],
          ),
        ));
  }

  Widget showPodcast(int index) {
    Widget result;
    switch (index) {
      case 0:
        result = defaultPage();
        break;
      case 1:
        result = PodcastEpisodes(podcast: currentPodcast);
        break;
      case 2:
        result = PodcasterFeaturedIn(podcaster: currentPodcaster);
        break;
      case 3:
        result = PodcastsOfTopic(topic: currentTopic);
        break;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: podcastIndex,
        builder: (BuildContext context, int value, Widget child) {
          return WillPopScope(
              onWillPop: () async {
                if (podcastIndex.value != 0)
                  podcastIndex.value = 0;
                else
                  currentIndex.value = 0;
                return false;
              },
              child: showPodcast(podcastIndex.value));
        });
  }
}
