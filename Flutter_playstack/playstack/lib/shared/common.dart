import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:playstack/screens/Library/Folder.dart';
import 'package:playstack/screens/Player/PlayerWidget.dart';
import 'package:playstack/screens/mainscreen.dart';
import 'package:playstack/models/FolderType.dart';
import 'package:playstack/models/PlaylistType.dart';
import 'package:playstack/models/Song.dart';
import 'package:playstack/models/user.dart';
import 'package:playstack/screens/Homescreen/Home.dart';
import 'package:playstack/screens/Homescreen/PublicProfile.dart';
import 'package:playstack/screens/Library/Library.dart';
import 'package:playstack/screens/Library/Playlist.dart';
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

var currentArtist;
var currentArtistImage;

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
String friendName;
bool leftAlready;
bool loadingUserData = true;
var rng = new Random();

Map<String, dynamic> languageStrings = new Map<String, dynamic>();

String songsNextUpName;
List songsNextUp = new List();
List songsPlayed = new List();
List following = new List();
List followers = new List();

List playlists = new List();

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
  double height = MediaQuery.of(context).size.height / 10;
  double iconsize = height / 3.2;
  double textsize = height / 10;
  return SizedBox(
      height: height,
      child: BottomNavigationBar(
          fixedColor: Colors.red[600],
          currentIndex: currentIndex,
          onTap: (int index) {
            currentIndex = index;
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => MainScreen()));
          },
          type: BottomNavigationBarType.shifting,
          items: [
            BottomNavigationBarItem(
                icon: new Icon(
                  CupertinoIcons.home,
                  size: iconsize,
                ),
                title: new Text(
                  "Home",
                  style: TextStyle(fontSize: textsize),
                )),
            BottomNavigationBarItem(
                icon: new Icon(CupertinoIcons.search, size: iconsize),
                title: new Text(
                  "Search",
                  style: TextStyle(fontSize: textsize),
                )),
            BottomNavigationBarItem(
                icon: new Icon(CupertinoIcons.collections, size: iconsize),
                title: new Text(
                  "Library",
                  style: TextStyle(fontSize: textsize),
                )),
            BottomNavigationBarItem(
                icon: new Icon(CupertinoIcons.music_note, size: iconsize),
                title: new Text("Play", style: TextStyle(fontSize: textsize))),
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
  final bool isNotOwn;

  SongItem(this.song, this.songsList, this.songsListName,
      {this.playlist, @required this.isNotOwn});

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
                        playlist != null && !isNotOwn
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
  final String image;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        leftAlready = false;
        currentArtist = artistName;
        currentArtistImage = image;
        homeIndex.value = 3;
      },
      child: Column(
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
      ),
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

List<DropdownMenuItem> listPlaylistNamesOfPlaylist(List availablePlaylists) {
  List<DropdownMenuItem> items = new List();
  for (var pl in availablePlaylists) {
    DropdownMenuItem newItem =
        new DropdownMenuItem<String>(value: pl.name, child: Text(pl.name));
    items.add(newItem);
  }
  return items;
}

void addingOrRemovingPlaylistToFolder(String playlistName, String folderName,
    bool adding, BuildContext context) async {
  adding
      ? Toast.show('Añadiendo ...', context,
          gravity: Toast.CENTER, backgroundColor: Colors.blue)
      : Toast.show('Retirando ...', context,
          gravity: Toast.CENTER, backgroundColor: Colors.blue);
  var result = adding
      ? await addPlaylistToFolder(playlistName, folderName)
      : await removePlaylistFromFolder(playlistName, folderName);
  try {
    if (result) {
      adding
          ? Toast.show('Playlist añadida!', context,
              gravity: Toast.CENTER, backgroundColor: Colors.green)
          : Toast.show('Playlist retirada!', context,
              gravity: Toast.CENTER, backgroundColor: Colors.green);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => MainScreen()));
    } else {
      adding
          ? Toast.show('No se pudo añadir la playlist', context,
              gravity: Toast.CENTER, backgroundColor: Colors.red)
          : Toast.show('No se pudo retirar la playlist', context,
              gravity: Toast.CENTER, backgroundColor: Colors.red);
      Navigator.of(context).pop();
    }
  } catch (e) {
    print("Exception " + e.toString());
  }
}

Future<void> showAddingOrRemovingPlaylistToFolderDialog(FolderType folder,
    List availablePlaylists, bool adding, BuildContext context) async {
  var dropdownItem = availablePlaylists.elementAt(0).name;
  return showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text(adding
              ? "Añadir a carpeta " + folder.name
              : "Eliminar de carpeta " + folder.name),
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
                      items: listPlaylistNamesOfPlaylist(availablePlaylists),
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
                              addingOrRemovingPlaylistToFolder(
                                  dropdownItem, folder.name, adding, context);
                            },
                            child: Text(adding ? "Añadir" : "Retirar")))
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

class FolderItem extends StatelessWidget {
  final FolderType folder;
  FolderItem(this.folder);
  @override
  Widget build(BuildContext context) {
    String playlistsInFolder = folder.containedPlaylists.elementAt(0).name;
    for (var i = 1; i < folder.containedPlaylists.length; i++) {
      playlistsInFolder = playlistsInFolder +
          ", " +
          folder.containedPlaylists.elementAt(i).name;
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
              case "AddPlaylist":
                //AddPlaylist
                List availablePlaylists = new List();
                for (var playlist in playlists) {
                  bool found = false;
                  int i = 0;
                  while (!found && i < folder.containedPlaylists.length) {
                    if (playlist.name ==
                        folder.containedPlaylists.elementAt(i).name)
                      found = true;

                    i++;
                  }
                  if (!found) availablePlaylists.add(playlist);
                }
                if (availablePlaylists.isNotEmpty) {
                  showAddingOrRemovingPlaylistToFolderDialog(
                      folder, availablePlaylists, true, context);
                } else {
                  Toast.show(
                      "No hay listas de reproducción que añadir", context,
                      duration: Toast.LENGTH_LONG,
                      gravity: Toast.CENTER,
                      backgroundColor: Colors.blue[500]);

                  Navigator.of(context).pop();
                }
                break;

              case "DeletePlaylist":
                if (folder.containedPlaylists.length == 1) {
                  Toast.show(
                      "Las carpetas deben contener al menos una playlist",
                      context,
                      duration: Toast.LENGTH_LONG,
                      gravity: Toast.CENTER,
                      backgroundColor: Colors.red[500]);
                  Navigator.of(context).pop();
                } else {
                  showAddingOrRemovingPlaylistToFolderDialog(
                      folder, folder.containedPlaylists, false, context);
                }

                break;
              default:
            }
          },
          itemBuilder: (context) => [
                PopupMenuItem(
                    value: "Delete",
                    child: ListTile(
                      leading: Icon(CupertinoIcons.delete, color: Colors.red),
                      title: Text("Eliminar carpeta"),
                    )),
                PopupMenuItem(
                    value: "AddPlaylist",
                    child: ListTile(
                      leading: Icon(CupertinoIcons.add),
                      title: Text("Añadir lista"),
                    )),
                PopupMenuItem(
                    value: "DeletePlaylist",
                    child: ListTile(
                      leading: Icon(
                        Icons.remove,
                      ),
                      title: Text("Quitar lista de reproducción"),
                    ))
              ]),
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (BuildContext context) => Folder(folder))),
    );
  }
}

class PlaylistItem extends StatelessWidget {
  final playlist;
  final bool listingInProfile;
  PlaylistItem(this.playlist, this.listingInProfile);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (listingInProfile) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => Playlist(
                    playlist,
                    isNotOwn: true,
                  )));
        } else {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => Playlist(playlist)));
        }
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
              listingInProfile
                  ? Text('')
                  : PopupMenuButton<String>(
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
                            bool deleted =
                                await deletePlaylistDB(playlist.name);
                            if (deleted) {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                    'Lista de reproducción borrada!',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.grey[700]));
                              //TODO: por ahora lo dejo asi aunque estaria bn buscar una alternativa
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      MainScreen()));
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

class UserTile extends StatelessWidget {
  final User user;
  final String tab;
  UserTile(this.user, this.tab);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      child: ListTile(
        leading: CircleAvatar(
            radius: 30, backgroundImage: NetworkImage(user.photoUrl)),
        title: Text(user.name),
        trailing: tab == "Requests" ? followRequestButtons(context) : Text(''),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => YourPublicProfile(
                  false,
                  friendUserName: user.name,
                  otherUser: user,
                ))),
      ),
    );
  }
}

Widget followRequestButtons(context) {
  var _width = MediaQuery.of(context).size.width / 2;
  return Container(
    width: _width,
    child: Row(
      children: <Widget>[
        Container(
          width: _width / 2.3,
          child: RaisedButton(
            onPressed: () => print("Acceptar"),
            child: Text("Aceptar"),
            color: Colors.lime[500],
          ),
        ),
        SizedBox(
          width: 15,
        ),
        Container(
          width: _width / 2.1,
          child: RaisedButton(
            onPressed: () => print("Rechazar"),
            child: Text("Rechazar"),
            color: Colors.red[500],
          ),
        )
      ],
    ),
  );
}
