import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:playstack/screens/Player/PlayerWidget.dart';
import 'package:playstack/screens/mainscreen.dart';
import 'package:playstack/models/FolderType.dart';
import 'package:playstack/models/PlaylistType.dart';
import 'package:playstack/models/Song.dart';
import 'package:playstack/screens/Homescreen/Home.dart';
import 'package:playstack/screens/Library/Library.dart';
import 'package:playstack/screens/Library/Playlist.dart';
import 'package:playstack/screens/Mainscreen.dart';
import 'package:playstack/screens/Player/PlayingNow.dart';
import 'package:playstack/screens/Search/SearchScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:playstack/services/database.dart';
import 'package:toast/toast.dart';

//////////////////////////////////////////////////////////////////////////////////
/////                   SHARED VARIABLES DO NOT TOUCH                       //////
//////////////////////////////////////////////////////////////////////////////////

enum PlayerState { stopped, playing, paused }

final ValueNotifier<int> homeIndex = ValueNotifier<int>(0);

var currentGenre;
var currentGenreImage;

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

Map<String, dynamic> languageStrings = new Map<String, dynamic>();

String songsNextUpName;
List songsNextUp = new List();
List songsPlayed = new List();

List playlists = new List();
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

List<Widget> mainScreens = [
  HomeScreen(),
  SearchScreen(),
  Library(),
  PlayingNowScreen()
];

// Para canciones de assets
AudioCache audioCache = AudioCache();
//Para canciones online SOLO HTTPS no HTTP
AudioPlayer advancedPlayer = AudioPlayer();

AudioPlayerState audioPlayerState;
Duration duration;
Duration position;
bool playerActive = false;

List<Song> allSongs = [];
bool onPlayerScreen = false;

PlayerState playerState = PlayerState.stopped;
PlayingRouteState playingRouteState = PlayingRouteState.SPEAKERS;
StreamSubscription durationSubscription;
StreamSubscription positionSubscription;
StreamSubscription playerCompleteSubscription;
StreamSubscription playerErrorSubscription;
StreamSubscription playerStateSubscription;

get isPlaying => playerState == PlayerState.playing;
get isPaused => playerState == PlayerState.paused;
get durationText => duration?.toString()?.split('.')?.first ?? '';
get positionText => position?.toString()?.split('.')?.first ?? '';

PlayerMode mode = PlayerMode.MEDIA_PLAYER;

Widget player;

/////////////////////////////////////////////////////////////////////////////////////

Future<String> loadLanguagesString() {
  Future<String> jsonString =
      rootBundle.loadString('assets/languages/spanish.json');
  return jsonString;
}

Widget extendedBottomBarWith(context, Widget widget) {
  var height = MediaQuery.of(context).size.height;
  return (onPlayerScreen || currentSong == null || player == null)
      ? widget
      : Container(
          height: height,
          child: Column(
            children: <Widget>[
              Expanded(child: widget),
              SizedBox(height: height * 0.15, child: player),
            ],
          ));
}

Widget bottomBar(context) {
  double height = MediaQuery.of(context).size.height * 0.1;
  return SizedBox(
      height: height,
      child: BottomNavigationBar(
          fixedColor: Colors.red[600],
          currentIndex: currentIndex,
          onTap: (int index) {
            currentIndex = index;
            if (currentIndex == 3) onPlayerScreen = true;
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => mainScreens[index]));
          },
          type: BottomNavigationBarType.shifting,
          items: [
            BottomNavigationBarItem(
                icon: new Icon(
                  CupertinoIcons.home,
                  size: height / 2.5,
                ),
                title: new Text(
                  "Home",
                  style: TextStyle(fontSize: height / 5),
                )),
            BottomNavigationBarItem(
                icon: new Icon(CupertinoIcons.search, size: height / 2.5),
                title: new Text(
                  "Search",
                  style: TextStyle(fontSize: height / 5),
                )),
            BottomNavigationBarItem(
                icon: new Icon(CupertinoIcons.collections, size: height / 2.5),
                title: new Text(
                  "Library",
                  style: TextStyle(fontSize: height / 5),
                )),
            BottomNavigationBarItem(
                icon: new Icon(CupertinoIcons.music_note, size: height / 2.5),
                title:
                    new Text("Play", style: TextStyle(fontSize: height / 5))),
          ]));
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
      onPlayerScreen = true;
      if (player == null) player = PlayerWidget();
      return player;
      break;
  }
}

class ProfilePicture extends StatefulWidget {
  @override
  ProfilePictureState createState() => ProfilePictureState();
}

class ProfilePictureState extends State<ProfilePicture> {
  static ValueNotifier<File> tempImage = ValueNotifier<File>(null);
  static void setTempImage(var newImage) {
    tempImage.value = newImage;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: ValueListenableBuilder(
            builder: (BuildContext context, File value, Widget child) {
              return CircleAvatar(
//backgroundColor: Color(0xFF191414),
                  radius: 60,
                  backgroundImage: (imagePath != null)
                      ? NetworkImage(imagePath)
                      : (tempImage.value != null)
                          ? FileImage(tempImage.value)
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
        onPlayerScreen = true;
        setShuffleQueue(songsListName, songslist, song);
        if (player == null) player = PlayerWidget();
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

List<DropdownMenuItem> listPlaylistNames() {
  List<DropdownMenuItem> items = new List();
  for (var pl in playlists) {
    DropdownMenuItem newItem =
        new DropdownMenuItem<String>(value: pl.name, child: Text(pl.name));
    items.add(newItem);
  }
  return items;
}

void addingSongToPlaylist(
    String playlistName, String songName, BuildContext context) async {
  var result = await addSongToPlaylistDB(playlistName, songName);
  try {
    if (result) {
      Toast.show('Canción añadida!', context,
          gravity: Toast.CENTER, backgroundColor: Colors.green);
    } else {
      Toast.show('No se pudo añadir la canción', context,
          gravity: Toast.CENTER, backgroundColor: Colors.red);
    }
  } catch (e) {
    print("Exception " + e.toString());
  }
  Navigator.of(context).pop();
}

Future<void> showAddingSongToPlaylistDialog(
    String songName, BuildContext context) async {
  var dropdownItem = playlists.elementAt(0).name;
  return showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text("Añadir a playlist"),
          elevation: 100.0,
          backgroundColor: Colors.grey[900],
          actions: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: DropdownButton(
                      isExpanded: true,
                      value: dropdownItem,
                      items: listPlaylistNames(),
                      onChanged: (val) {
                        setState(() {
                          dropdownItem = val;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Builder(
              builder: (context) => Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                        flex: 1,
                        child: FlatButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Cancelar"))),
                    Expanded(
                        flex: 1,
                        child: FlatButton(
                            onPressed: () {
                              addingSongToPlaylist(
                                  dropdownItem, songName, context);
                            },
                            child: Text("Añadir")))
                  ],
                ),
              ),
            )
          ],
        );
      });
    },
  );
}

class SongItem extends StatelessWidget {
  final String songsListName;
  final List songsList;
  final Song song;
  final PlaylistType playlist;

  SongItem(this.song, this.songsList, this.songsListName, {this.playlist});

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
        onPlayerScreen = true;
        if (player == null) player = PlayerWidget();
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
                        fontSize: MediaQuery.of(context).size.height / 40),
                  ),
                  SizedBox(height: 5),
                  Text(
                    getSongArtists(song.artists),
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: MediaQuery.of(context).size.height / 50),
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
                      case "AddToPlaylist":
                        playlists = await getUserPlaylists();
                        showAddingSongToPlaylistDialog(song.title, context);
                        break;
                      case "removeFromPlaylist":
                        await removeSongFromPlaylistDB(
                            song.title, playlist.name);
                        await playlist.updateCovers();
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                Playlist(playlist)));
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
                            value: "AddToPlaylist",
                            child: ListTile(
                              leading: Icon(CupertinoIcons.add),
                              title: Text("Añadir canción a playlist"),
                            )),
                        playlist != null
                            ? PopupMenuItem(
                                value: "removeFromPlaylist",
                                child: ListTile(
                                  leading: Icon(CupertinoIcons.delete),
                                  title: Text("Eliminar canción de lista"),
                                ))
                            : null,
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
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        currentSong = song;
        songsNextUp.remove(currentSong);
        // Se notifica que la canción se escucha
        currentSong.markAsListened();
        onPlayerScreen = true;
        if (player == null) player = PlayerWidget();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => PlayingNowScreen()));
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          height: height / 13,
          width: width,
          child: Row(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    height: height / 13,
                    width: width / 5.8,
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
              SizedBox(width: width / 25),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    song.title,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: height / 40),
                  ),
                  SizedBox(height: 5),
                  Text(
                    getSongArtists(song.artists),
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: height / 50),
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
    case 3:
      return Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                  flex: 1, child: Image.network(insideCoverUrls.elementAt(0))),
              Expanded(
                  flex: 1, child: Image.network(insideCoverUrls.elementAt(1))),
            ],
          ),
          Expanded(flex: 1, child: Image.network(insideCoverUrls.elementAt(2)))
        ],
      );
      break;
    case 4:
      return Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                  flex: 1, child: Image.network(insideCoverUrls.elementAt(0))),
              Expanded(
                  flex: 1, child: Image.network(insideCoverUrls.elementAt(1))),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                  flex: 1, child: Image.network(insideCoverUrls.elementAt(2))),
              Expanded(
                  flex: 1, child: Image.network(insideCoverUrls.elementAt(3))),
            ],
          ),
        ],
      );

      break;
    default:
      return Image.asset(
        'assets/images/defaultCover.png',
        fit: BoxFit.cover,
      );
  }
}

class FolderItem extends StatelessWidget {
  final FolderType folder;
  FolderItem(this.folder);
  @override
  Widget build(BuildContext context) {
    String playlistsInFolder = folder.containedPlaylists.elementAt(0);
    for (var i = 1; i < folder.containedPlaylists.length; i++) {
      playlistsInFolder =
          playlistsInFolder + ", " + folder.containedPlaylists.elementAt(i);
    }
    return ListTile(
        leading: Container(
          height: MediaQuery.of(context).size.height / 13,
          width: MediaQuery.of(context).size.width / 6.5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Icon(CupertinoIcons.folder, size: 30),
          ),
        ),
        title: Text(folder.name,
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500)),
        subtitle: Text(playlistsInFolder),
        trailing: PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz),
            color: Colors.grey[800],
            onSelected: (val) async {
              switch (val) {
                case "Delete":
                  Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text(
                        'Borrando carpeta...',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.grey[700]));
                  bool deleted = await deleteFolderDB(folder.name);
                  if (deleted) {
                    Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text(
                          'Carpeta borrada!',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.grey[700]));
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => MainScreen()));
                  } else {
                    Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text(
                          'No se pudo borrar la carpeta',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.grey[700]));
                  }

                  break;
                default:
                  null;
              }
            },
            itemBuilder: (context) => [
                  PopupMenuItem(
                      value: "Delete",
                      child: ListTile(
                        leading: Icon(CupertinoIcons.delete),
                        title: Text("Eliminar carpeta"),
                      )),
                ]),
        onTap: () =>
            null /* Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) =>
              Playlist(new PlaylistType(name: "Favoritas")))), */
        );
  }
}

class PlaylistItem extends StatelessWidget {
  final playlist;
  PlaylistItem(this.playlist);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => Playlist(playlist)));
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
                        fontSize: 20.0),
                  ),
                  SizedBox(height: 5),
                ],
              ),
              Spacer(),
              PopupMenuButton<String>(
                  icon: Icon(Icons.more_horiz),
                  color: Colors.grey[800],
                  onSelected: (val) async {
                    switch (val) {
                      case "Delete":
                        Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text(
                              'Borrando lista de reproducción...',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.grey[700]));
                        bool deleted = await deletePlaylistDB(playlist.name);
                        if (deleted) {
                          Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text(
                                'Lista de reproducción borrada!',
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.grey[700]));
                          //TODO: por ahora lo dejo asi aunque estaria bn buscar una alternativa
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) => MainScreen()));
                        } else {
                          Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text(
                                'No se pudo borrar la lista de reproducción',
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.grey[700]));
                        }

                        break;
                      default:
                        null;
                    }
                  },
                  itemBuilder: (context) => [
                        PopupMenuItem(
                            value: "Delete",
                            child: ListTile(
                              leading: Icon(CupertinoIcons.delete),
                              title: Text("Eliminar playlist"),
                            )),
                      ])
            ],
          ),
        ),
      ),
    );
  }
}
