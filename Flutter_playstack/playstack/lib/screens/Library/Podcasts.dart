import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playstack/models/Album.dart';
import 'package:playstack/models/Artist.dart';
import 'package:playstack/models/Episode.dart';
import 'package:playstack/models/PlaylistType.dart';
import 'package:playstack/models/Podcast.dart';
import 'package:playstack/models/Song.dart';
import 'package:playstack/screens/Library/Language.dart';
import 'package:playstack/screens/Library/Playlist.dart';
import 'package:playstack/services/database.dart';
import 'package:playstack/shared/Loading.dart';
import 'package:playstack/shared/common.dart';
import 'package:toast/toast.dart';
import 'package:lipsum/lipsum.dart' as lipsum;

List episodesExample() {
  List<Episode> exampleList = List<Episode>();
  exampleList.add(Episode(
      title: "Episode1",
      albumCoverUrls: null,
      topics: null,
      artists: null,
      url: "",
      duration: 5,
      date: "20/20/20"));
  exampleList.add(Episode(
      title: "Episode2",
      albumCoverUrls: null,
      topics: null,
      artists: null,
      url: "",
      duration: 15,
      date: "7/3/20"));
  return exampleList;
}

List getExampleList() {
  List<Podcast> exampleList = List<Podcast>();
  exampleList.add(Podcast(
      title: "Example1",
      coverUrl: 'lib/assets/Photos/logo.png',
      hosts: null,
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

List<Podcast> _favPodcastList = getPodcastsDB();

Widget favPodcasts(context) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;
  return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: _favPodcastList.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (context, int index) {
        return GestureDetector(
            onTap: () {
              currentPodcast = _favPodcastList[index];
              podcastIndex.value = 1;
            },
            child: SizedBox(
                height: height / 3.5,
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
                        padding: EdgeInsets.fromLTRB(
                            width / 20, width / 20, width / 20, width / 20),
                        child: Column(children: <Widget>[
                          Expanded(
                              flex: 2,
                              child: Row(children: <Widget>[
                                Expanded(
                                    flex: 1,
                                    child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.asset(
                                          _favPodcastList[index].coverUrl,
                                          fit: BoxFit.cover,
                                        ))),
                                Expanded(
                                    flex: 4,
                                    child: Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            width / 10, 0, 0, 0),
                                        child: Text(
                                            _favPodcastList[index].title,
                                            style: TextStyle(
                                                fontSize: width / 15,
                                                fontWeight: FontWeight.w500))))
                              ])),
                          Expanded(
                              flex: 4,
                              child: LayoutBuilder(
                                  builder: (context, constraints) {
                                String aux = "";
                                String descP1 = "";
                                String descP2 = "";
                                List<String> descList =
                                    _favPodcastList[index].desc.split(" ");
                                int i = 0;
                                bool exceeded = false;
                                while (i < descList.length && !exceeded) {
                                  if (aux != "") aux += " ";
                                  aux += descList[i];
                                  var tp = TextPainter(
                                      maxLines: 3,
                                      textAlign: TextAlign.left,
                                      textDirection: TextDirection.ltr,
                                      text: TextSpan(
                                        text: aux,
                                        style:
                                            TextStyle(fontSize: width / 23.5),
                                      ));
                                  tp.layout(
                                      maxWidth: width * 0.85,
                                      minWidth: width * 0.85);
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
                                      height: height * 0.1,
                                      width: width * 0.95,
                                      child: Text(descP1,
                                          textAlign: TextAlign.justify,
                                          maxLines: 3,
                                          style: TextStyle(
                                              fontSize: width / 23.5,
                                              color: Colors.white
                                                  .withOpacity(0.7)))),
                                  Expanded(
                                      child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                  right: width * 0.05),
                                              child: Text(descP2,
                                                  textAlign: TextAlign.justify,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      fontSize: width / 23.5,
                                                      color: Colors.white
                                                          .withOpacity(0.7))))),
                                      _favPodcastList[index]
                                          .language
                                          .showPodcastLanguage(context),
                                    ],
                                  ))
                                ]);
                              }))
                        ])))));
      });
}

Widget podcastCollaborators() {
  return Center(child: Text("Colaboradores"));
}

Widget discoverPodcasts() {
  return Center(child: Text("Descubrir"));
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
              favPodcasts(context),
              podcastCollaborators(),
              discoverPodcasts()
            ],
          ),
        ));
  }

  Widget podcastEpisodes(Podcast podcast) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => podcastIndex.value = 0),
          centerTitle: true,
          title: Text(podcast.title,
              style: TextStyle(
                  fontFamily: 'Circular',
                  fontSize: MediaQuery.of(context).size.width / 18)),
        ),
        body: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: podcast.episodes.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, int index) {
              return GestureDetector(
                  onTap: () {
                    currentAudio = podcast.episodes[index];
                    homeIndex.value = 3;
                  },
                  child: SizedBox(
                      height: height / 5,
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
                                Container(
                                    width: width / 5,
                                    height: width / 5,
                                    child: Stack(children: <Widget>[
                                      Container(
                                          width: width / 6,
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Image.asset(
                                                podcast.coverUrl,
                                                fit: BoxFit.cover,
                                              ))),
                                      Align(
                                          alignment: Alignment.bottomRight,
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(2.0),
                                              child: Container(
                                                  width: width / 10,
                                                  height: width / 15,
                                                  color: Colors.white,
                                                  child: Text(
                                                      (index + 1).toString(),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: width / 20,
                                                          color:
                                                              Colors.black)))))
                                    ])),
                                Expanded(
                                    child: Container(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                      Expanded(
                                          flex: 2,
                                          child: Text(
                                              languageStrings['released'] +
                                                  " " +
                                                  podcast.episodes[index].date,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  fontSize: width / 30,
                                                  color: Colors.white
                                                      .withOpacity(0.7)))),
                                      Expanded(
                                          flex: 5,
                                          child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  width / 20, 0, 0, 0),
                                              child: Text(
                                                  podcast.episodes[index].title,
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontSize: width / 15,
                                                      fontWeight:
                                                          FontWeight.w500)))),
                                      Expanded(
                                          flex: 2,
                                          child: Row(children: <Widget>[
                                            Spacer(),
                                            Container(
                                                alignment:
                                                    Alignment.bottomRight,
                                                width: width / 20,
                                                child: Text(
                                                    //TODO: Hay que mejorar
                                                    podcast.episodes[index]
                                                        .duration
                                                        .toString(),
                                                    textAlign: TextAlign.right,
                                                    style: TextStyle(
                                                        fontSize: width / 23.5,
                                                        color: Colors.white
                                                            .withOpacity(0.7))))
                                          ]))
                                    ])))
                              ])))));
            }));
  }

  Widget showPodcast(int index) {
    Widget result;
    switch (index) {
      case 0:
        result = defaultPage();
        break;
      case 1:
        result = podcastEpisodes(currentPodcast);
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
                podcastIndex.value = 0;
                return false;
              },
              child: showPodcast(podcastIndex.value));
        });
  }
}
