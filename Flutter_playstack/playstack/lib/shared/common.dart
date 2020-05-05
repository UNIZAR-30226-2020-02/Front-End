import 'dart:math';
import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:playstack/models/Song.dart';
import 'package:playstack/screens/Homescreen/Home.dart';
import 'package:playstack/screens/Library/Library.dart';
import 'package:playstack/screens/Player/PlayingNow.dart';
import 'package:playstack/screens/Search/SearchScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//////////////////////////////////////////////////////////////////////////////////
/////                   SHARED VARIABLES DO NOT TOUCH                       //////
//////////////////////////////////////////////////////////////////////////////////

var dio = Dio();
var defaultImagePath =
    'https://i7.pngguru.com/preview/753/432/885/user-profile-2018-in-sight-user-conference-expo-business-default-business.jpg';
var imagePath;

var backgroundColor = Color(0xFF191414);

String userName;
String userEmail;
int currentIndex = 0;
Song currentSong;
String kindOfAccount = 'No premium';
var rng = new Random();

Map<String,dynamic> languageStrings;

String songsNextUpName;
List songsNextUp = new List();
List songsPlayed = new List();

List<Widget> mainScreens = [
  HomeScreen(),
  SearchScreen(),
  Library(),
  PlayingNowScreen()
];

/////////////////////////////////////////////////////////////////////////////////////

void loadLanguagesString() async{
  String jsonString = await rootBundle.loadString('assets/languages/english.json');
  languageStrings = jsonDecode(jsonString);
  print("Loaded ${languageStrings['language']}");
}

Widget show(int index) {
  switch (index) {
    case 0:
      return HomeScreen();
      break;
    case 1:
      return SearchScreen();
      break;
    case 2:
      return Library();
      break;
    case 3:
      return PlayingNowScreen();
      break;
  }
}

class ProfilePicture extends StatefulWidget {
  @override
  ProfilePictureState createState() => ProfilePictureState();
}

class ProfilePictureState extends State<ProfilePicture> {
  static ValueNotifier<File> tempImage = ValueNotifier<File>(null);
  static void setTempImage(var newImage){
    tempImage.value = newImage;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
     child : ValueListenableBuilder(
    builder: (BuildContext context, File value, Widget child){
      return CircleAvatar(
//backgroundColor: Color(0xFF191414),
        radius: 60,
        backgroundImage: (imagePath != null)
            ? NetworkImage(imagePath)
            : (tempImage.value != null)? FileImage(tempImage.value)
            : NetworkImage(defaultImagePath));
  },
  valueListenable: tempImage));
  }
}

void setShuffleQueue(String songsListName, List songsList, Song firstSong) {
  List tmpList = new List();
  tmpList.addAll(songsList);
  tmpList.remove(firstSong);
  songsNextUpName = songsListName;
  currentSong = firstSong;
  songsNextUp = tmpList;
  firstSong.markAsListened();
}

Widget playlistsDivider() {
  return Divider(
    color: Colors.white70,
    indent: 20,
    endIndent: 20,
  );
}

Widget shuffleButton(
    String songsListName, List songslist, BuildContext context) {
  Song song;

  if (songslist.isNotEmpty) {
    song = songslist.elementAt(rng.nextInt(songslist.length));
  }
  return Container(
    height: 45.0,
    width: MediaQuery.of(context).size.width / 3,
    child: RaisedButton(
      onPressed: () {
        setShuffleQueue(songsListName, songslist, song);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => PlayingNowScreen()));
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
      padding: EdgeInsets.all(0.0),
      child: Ink(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red[900], Colors.red[400], Colors.red[900]],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(30.0)),
        child: Container(
          constraints: BoxConstraints(maxWidth: 300.0, minHeight: 50.0),
          alignment: Alignment.center,
          child: Text(
            "Aleatorio",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
      ),
    ),
  );
}

// Check if its a digit
bool isDigit(String s) => "0".compareTo(s[0]) <= 0 && "9".compareTo(s[0]) >= 0;

// Checks if the password is secure enough
bool passwordIsSafe(String password) {
  bool isSafe = false;
  var char = '';

  if (password.length >= 8) {
    for (int i = 0; i < password.length; i++) {
      char = password.substring(i, i + 1);
      if (!isDigit(char)) {
        if (char == char.toUpperCase()) {
          isSafe = true;
        }
      }
    }
  }
  return isSafe;
}

String getSongArtists(List artists) {
  String res = artists.elementAt(0);
  for (var i = 1; i < artists.length; i++) {
    res = res + "," + artists.elementAt(i);
  }
  return res;
}

class SongItem extends StatelessWidget {
  final String songsListName;
  final List songsList;
  final Song song;

  SongItem(this.song, this.songsList, this.songsListName);

  void setQueue(List songsList) {
    List tmpList = new List();
    tmpList.addAll(songsList);
    tmpList.remove(song);
    songsNextUpName = songsListName;
    currentSong = song;
    songsNextUp = tmpList;
    print("Tocada se marcara como escuchada");
    song.markAsListened();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setQueue(songsList);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => PlayingNowScreen()));
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          height: MediaQuery.of(context).size.height / 13,
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height / 13,
                    width: MediaQuery.of(context).size.width / 5.8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        song.albumCoverUrls.elementAt(0),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                      height: MediaQuery.of(context).size.height / 13,
                      width: 80.0,
                      child: Icon(
                        Icons.play_circle_filled,
                        color: Colors.white.withOpacity(0.7),
                        size: 42.0,
                      ))
                ],
              ),
              SizedBox(width: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    song.title,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0),
                  ),
                  SizedBox(height: 5),
                  Text(
                    getSongArtists(song.artists),
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5), fontSize: 18.0),
                  ),
                ],
              ),
              Spacer(),
              PopupMenuButton<String>(
                  icon: Icon(Icons.more_horiz),
                  color: Colors.grey[800],
                  onSelected: (val) async {
                    switch (val) {
                      case "Fav":
                        if (song.isFav) {
                          song.removeFromFavs();
                        } else {
                          song.setAsFav();
                        }
                        break;
                      default:
                        showSharableLink(context, song.url);
                    }
                  },
                  itemBuilder: (context) => [
                        PopupMenuItem(
                            value: "Fav",
                            child: ListTile(
                              leading: Icon(
                                song.isFav
                                    ? CupertinoIcons.heart_solid
                                    : CupertinoIcons.heart,
                                color: Colors.red,
                              ),
                              title: Text(song.isFav
                                  ? "Quitar de favoritos"
                                  : "Añadir a favoritos"),
                            )),
                        PopupMenuItem(
                            value: "Share",
                            child: ListTile(
                              leading: Icon(CupertinoIcons.share),
                              title: Text('Compartir'),
                            ))
                      ])
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showSharableLink(BuildContext context, String url) {
  return showDialog(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Compartir enlace"),
        content: Text(url),
        elevation: 100.0,
        actions: <Widget>[
          FlatButton(
              onPressed: () => Navigator.pop(context), child: Text("Listo"))
        ],
      );
    },
  );
}

class ArtistItem extends StatelessWidget {
  ArtistItem(this.artistName, this.image);

  final String artistName;
  final image;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 130.0,
          width: 140.0,
          child: Image.asset(
            image,
            fit: BoxFit.fitHeight,
          ),
        ),
        Padding(padding: EdgeInsets.all(5.0)),
        Text(
          artistName,
          style: TextStyle(
            color: Colors.white.withOpacity(1.0),
            fontSize: 15.0,
          ),
        )
      ],
    );
  }
}

class GenericSongItem extends StatelessWidget {
  final Song song;
  GenericSongItem(this.song);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        currentSong = song;
        songsNextUp.remove(currentSong);
        // Se notifica que la canción se escucha
        currentSong.markAsListened();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => PlayingNowScreen()));
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          height: MediaQuery.of(context).size.height / 13,
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height / 13,
                    width: MediaQuery.of(context).size.width / 5.8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        song.albumCoverUrls.elementAt(0),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    song.title,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0),
                  ),
                  SizedBox(height: 5),
                  Text(
                    getSongArtists(song.artists),
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5), fontSize: 18.0),
                  ),
                ],
              ),
              Spacer(),
              Icon(
                Icons.more_horiz,
                color: Colors.white.withOpacity(0.6),
                size: 32.0,
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget playListCover(List insideCoverUrls) {
  switch (insideCoverUrls.length) {
    case 0:
      return Image.asset(
        'assets/images/defaultCover.png',
        fit: BoxFit.cover,
      );
      break;
    case 1:
      return Image.network(insideCoverUrls.elementAt(0));
      break;
    case 2:
      return Row(
        children: <Widget>[
          Expanded(flex: 1, child: Image.network(insideCoverUrls.elementAt(0))),
          Expanded(flex: 1, child: Image.network(insideCoverUrls.elementAt(1))),
        ],
      );
      break;

    default:
  }
}

//TODO: poner las fotos de las canciones de dentro
class PlaylistItem extends StatelessWidget {
  final playlist;
  PlaylistItem(this.playlist);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => PlayingNowScreen()));
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          height: MediaQuery.of(context).size.height / 13,
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height / 13,
                    width: MediaQuery.of(context).size.width / 5.8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: playListCover(playlist.coverUrls),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    playlist.name,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0),
                  ),
                  SizedBox(height: 5),
                ],
              ),
              Spacer(),
              Icon(
                Icons.more_horiz,
                color: Colors.white.withOpacity(0.6),
                size: 32.0,
              )
            ],
          ),
        ),
      ),
    );
  }
}
