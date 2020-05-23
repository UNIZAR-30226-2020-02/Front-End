import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:playstack/models/Artist.dart';
import 'package:flutter/foundation.dart';
import 'package:playstack/models/Audio.dart';
import 'package:playstack/models/Genre.dart';
import 'package:playstack/models/LocalSongsPlaylists.dart';
import 'package:playstack/models/Podcast.dart';
import 'package:playstack/models/user.dart';
import 'package:playstack/screens/Homescreen/PublicProfile.dart';
import 'package:playstack/screens/Library/Folder.dart';
import 'package:playstack/screens/Player/PlayerWidget.dart';
import 'package:playstack/screens/MainScreen.dart';
import 'package:playstack/models/FolderType.dart';
import 'package:playstack/models/PlaylistType.dart';
import 'package:playstack/models/Song.dart';
import 'package:playstack/screens/Homescreen/Home.dart';
import 'package:playstack/screens/Library/Library.dart';
import 'package:playstack/screens/Library/Playlist.dart';
import 'package:playstack/screens/Player/PlayingNow.dart';
import 'package:playstack/screens/Search/SearchScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:playstack/services/database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toast/toast.dart';
import 'package:playstack/services/SQLite.dart';

//////////////////////////////////////////////////////////////////////////////////
/////                   SHARED VARIABLES DO NOT TOUCH                       //////
//////////////////////////////////////////////////////////////////////////////////

final ValueNotifier<int> homeIndex = ValueNotifier<int>(0);

Genre currentGenre;

PlaylistType currentPlaylist;
bool currentPlaylistInNotOwn;

bool viewingOwnPublicProfile = true;

String friendUserName = '';
User otherUser = new User('', '');

int previousIndex = 0;

List<Song> recentlyPlayedSongs = new List();
List<Podcast> recentlyPlayedPodcasts = new List();

List<Song> songsMostListenedTo = new List();
List<Podcast> podcastsmostListenedTo = new List();

var currentArtist;
var currentArtistImage;

var dio = Dio();
var defaultImagePath =
    'https://i7.pngguru.com/preview/753/432/885/user-profile-2018-in-sight-user-conference-expo-business-default-business.jpg';
var imagePath;

var backgroundColor = Color(0xFF191414);

String userName;
String userEmail;
final ValueNotifier<int> currentIndex = ValueNotifier<int>(0);
Audio currentAudio;
String accountType = 'No premium';
String defaultCover = "assets/images/defaultCover.png";
String friendName;
bool loadingUserData = true;
var rng = new Random();

final ValueNotifier<int> podcastIndex = ValueNotifier<int>(0);
Podcast currentPodcast;
Artist currentPodcaster;
String currentTopic;

Map<String, dynamic> languageStrings = new Map<String, dynamic>();

String songsNextUpName;
List songsNextUp = new List();
List songsPlayed = new List();
List following = new List();
List followers = new List();
List localPlaylistList = new List();

List playlists = new List();

List<Widget> mainScreens = [
  HomeScreen(),
  SearchScreen(),
  Library(),
  PlayingNowScreen()
];

enum PlayerState { stopped, playing, paused }

// Para canciones de assets
AudioCache audioCache = AudioCache();
//Para canciones online SOLO HTTPS no HTTP
AudioPlayer advancedPlayer = AudioPlayer();
AudioPlayerState audioPlayerState;

PlayerState playerState = PlayerState.stopped;

PlayerMode mode = PlayerMode.MEDIA_PLAYER;

Duration position;

Duration duration;
bool playerActive = false;

List<Audio> allAudios = [];
bool onPlayerScreen = false;
bool shuffleEnabled;

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

Widget player;

Future<Database> database;

/////////////////////////////////////////////////////////////////////////////////////

Future<String> loadLanguagesString() {
  Future<String> jsonString =
      rootBundle.loadString('assets/languages/spanish.json');
  return jsonString;
}

Widget extendedBottomBarWith(context, Widget widget) {
  var height = MediaQuery.of(context).size.height;
  return (onPlayerScreen || currentAudio == null || player == null)
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
          currentIndex: currentIndex.value,
          onTap: (int index) {
            currentIndex.value = index;
            if (currentIndex.value == 3) onPlayerScreen = true;
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
  currentAudio = firstSong;
  songsNextUp = tmpList;
  allAudios.clear();
  allAudios.add(currentAudio);
  for (var item in songsNextUp) {
    allAudios.add(item);
  }
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
        shuffleEnabled = true;

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
        new DropdownMenuItem<String>(value: pl.title, child: Text(pl.title));
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
  var dropdownItem = playlists.elementAt(0).title;
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

void setQueue(List songsList, Song song, String songsListName) {
  List tmpList = new List();
  tmpList.addAll(songsList);
  tmpList.remove(song);
  songsNextUpName = songsListName;
  currentAudio = song;
  songsNextUp = tmpList;
  allAudios.clear();
  allAudios.add(currentAudio);
  for (var item in songsNextUp) {
    allAudios.add(item);
  }
  song.markAsListened();
}

class SongItem extends StatelessWidget {
  final String songsListName;
  final List songsList;
  final Song song;
  final PlaylistType playlist;
  final bool isNotOwn;
  final onRemovedFromFavsCallBack;

  SongItem(this.song, this.songsList, this.songsListName,
      {this.playlist, @required this.isNotOwn, this.onRemovedFromFavsCallBack});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setQueue(songsList, song, songsListName);
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
                      child: song.isLocal
                          ? Image.asset(defaultCover, fit: BoxFit.cover)
                          : Image.network(
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
                  Container(
                    width: MediaQuery.of(context).size.width / 2.2,
                    child: Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.height / 45),
                    ),
                  ),
                  SizedBox(height: 5),
                  song.isLocal
                      ? Text("")
                      : Text(
                          getSongArtists(song.artists),
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize:
                                  MediaQuery.of(context).size.height / 50),
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
                        bool res = false;
                        if (song.isFav) {
                          res = await song.removeFromFavs();
                          if (res)
                            Toast.show('Eliminada!', context,
                                gravity: Toast.CENTER,
                                duration: Toast.LENGTH_LONG,
                                backgroundColor: Colors.green);
                          if (playlist.title == "Favoritas")
                            onRemovedFromFavsCallBack();
                          else
                            Toast.show('Error quitando de favoritas!', context,
                                gravity: Toast.CENTER,
                                duration: Toast.LENGTH_LONG,
                                backgroundColor: Colors.red);
                        } else {
                          res = await song.setAsFav();
                          if (res)
                            Toast.show('Añadida!', context,
                                gravity: Toast.CENTER,
                                duration: Toast.LENGTH_LONG,
                                backgroundColor: Colors.green);
                          else
                            Toast.show('Error añadiendo a favoritas', context,
                                gravity: Toast.CENTER,
                                duration: Toast.LENGTH_LONG,
                                backgroundColor: Colors.red);
                        }
                        break;
                      case "AddToPlaylist":
                        if (song.isLocal) {
                        } else {
                          playlists = await getUserPlaylists();
                          showAddingSongToPlaylistDialog(song.title, context);
                        }

                        break;
                      case "removeFromPlaylist":
                        if (song.isLocal) {
                        } else {
                          await removeSongFromPlaylistDB(
                              song.title, playlist.title);
                          await playlist.updateCovers();
                        }

                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                Playlist(playlist)));
                        break;

                      default:
                        showSharableLink(context, song.url);
                    }
                  },
                  itemBuilder: (context) => [
                        if (!song.isLocal)
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
                        playlist != null &&
                                !isNotOwn &&
                                playlist.title != "Favoritas"
                            ? PopupMenuItem(
                                value: "removeFromPlaylist",
                                child: ListTile(
                                  leading: Icon(CupertinoIcons.delete),
                                  title: Text("Eliminar canción de lista"),
                                ))
                            : null,
                        if (!song.isLocal)
                          PopupMenuItem(
                              value: "Share",
                              child: ListTile(
                                leading: Icon(CupertinoIcons.share),
                                title: Text('Compartir'),
                              )),
                      ])
            ],
          ),
        ),
      ),
    );
  }
}

List<DropdownMenuItem> _listLocalPlaylistNames() {
  List<DropdownMenuItem> items = new List();
  if (accountType == "Premium") {
    for (var pl in playlists) {
      DropdownMenuItem newItem =
          new DropdownMenuItem<String>(value: pl.title, child: Text(pl.title));
      items.add(newItem);
    }
  }
  for (var pl in localPlaylistList) {
    DropdownMenuItem newItem =
        new DropdownMenuItem<String>(value: pl.name, child: Text(pl.name));
    items.add(newItem);
  }
  return items;
}

Future<void> _showAddingSongToPlaylistDialog(
    String songName, BuildContext context) async {
  var dropdownItem = localPlaylistList.elementAt(0).name;
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
                      items: _listLocalPlaylistNames(),
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
                            onPressed: () async {
                              LocalSongsPlaylists newEntry =
                                  new LocalSongsPlaylists(
                                      id: "$songName$dropdownItem",
                                      songName: songName,
                                      playlistName: dropdownItem);

                              int inserted =
                                  await insertSongToPlaylist(newEntry);
                              if (inserted > 0)
                                Toast.show('Añadida!', context,
                                    gravity: Toast.CENTER,
                                    duration: Toast.LENGTH_LONG,
                                    backgroundColor: Colors.green);
                              else
                                Toast.show(
                                    'Error añadiendo cancion a lista', context,
                                    gravity: Toast.CENTER,
                                    duration: Toast.LENGTH_LONG,
                                    backgroundColor: Colors.red);
                              Navigator.of(context).pop();
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

class LocalSongItem extends StatelessWidget {
  final Song song;
  final List songsList;
  final String songsListName;
  final String playlistName;
  final onDeletedCallBack;

  LocalSongItem(this.song, this.songsList, this.songsListName,
      {this.playlistName, @required this.onDeletedCallBack});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setQueue(songsList, song, songsListName);
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
                        child: Image.asset(defaultCover, fit: BoxFit.cover)),
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
                ],
              ),
              Spacer(),
              PopupMenuButton<String>(
                  icon: Icon(Icons.more_horiz),
                  color: Colors.grey[800],
                  onSelected: (val) async {
                    switch (val) {
                      case "Remove":
                        await deleteLocalSongFromEveryWhere(song, context);
                        onDeletedCallBack();

                        break;

                      case "AddToPlaylist":
                        _showAddingSongToPlaylistDialog(song.title, context);
                        break;
                      case "removeFromPlaylist":
                        int deleted = await deleteSongFromPlaylist(
                            song.title, playlistName);
                        if (deleted > 0) {
                          Toast.show('Canción eliminada de la lista', context,
                              gravity: Toast.CENTER,
                              duration: Toast.LENGTH_LONG,
                              backgroundColor: Colors.green);
                          onDeletedCallBack();
                        } else {
                          Toast.show(
                              'Error eliminando canción de lista', context,
                              gravity: Toast.CENTER,
                              duration: Toast.LENGTH_LONG,
                              backgroundColor: Colors.red);
                        }
                        break;
                      default:
                        null;
                    }
                  },
                  itemBuilder: (context) => [
                        PopupMenuItem(
                            value: "Remove",
                            child: ListTile(
                              leading: Icon(CupertinoIcons.delete),
                              title: Text("Eliminar canción de la aplicación"),
                            )),
                        PopupMenuItem(
                            value: "AddToPlaylist",
                            child: ListTile(
                              leading: Icon(CupertinoIcons.add),
                              title: Text("Añadir canción a playlist"),
                            )),
                        if (playlistName != null)
                          PopupMenuItem(
                              value: "removeFromPlaylist",
                              child: ListTile(
                                leading: Icon(CupertinoIcons.delete),
                                title: Text("Eliminar canción de lista"),
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
        content: SelectableText(url),
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
        currentArtist = artistName;
        currentArtistImage = image;
        homeIndex.value = 4;
      },
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 130.0,
            width: 140.0,
            child: Image.network(
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

class GenericAudioItem extends StatelessWidget {
  final Audio audio;
  GenericAudioItem(this.audio);
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        currentAudio = audio;
        songsNextUp.remove(currentAudio);
        // Se notifica que la canción se escucha
        currentAudio.markAsListened();
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
                        audio.albumCoverUrls.elementAt(0),
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
                    audio.title,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: height / 40),
                  ),
                  SizedBox(height: 5),
                  Text(
                    getSongArtists(audio.artists),
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
        defaultCover,
        fit: BoxFit.cover,
      );
      break;
    case 1:
      return Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(
              fit: BoxFit.cover,
              alignment: FractionalOffset.topCenter,
              image: NetworkImage(insideCoverUrls.elementAt(0))),
        ),
      );
      break;
    case 2:
      return Row(
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Container(
              decoration: new BoxDecoration(
                image: new DecorationImage(
                    fit: BoxFit.cover,
                    alignment: FractionalOffset.topCenter,
                    image: NetworkImage(insideCoverUrls.elementAt(0))),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Container(
              decoration: new BoxDecoration(
                image: new DecorationImage(
                    fit: BoxFit.cover,
                    alignment: FractionalOffset.topCenter,
                    image: NetworkImage(insideCoverUrls.elementAt(1))),
              ),
            ),
          ),
        ],
      );
      break;
    case 3:
      return Column(
        children: <Widget>[
          Flexible(
            flex: 5,
            child: Row(
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Container(
                    decoration: new BoxDecoration(
                      image: new DecorationImage(
                          fit: BoxFit.cover,
                          alignment: FractionalOffset.topCenter,
                          image: NetworkImage(insideCoverUrls.elementAt(0))),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    decoration: new BoxDecoration(
                      image: new DecorationImage(
                          fit: BoxFit.cover,
                          alignment: FractionalOffset.topCenter,
                          image: NetworkImage(insideCoverUrls.elementAt(1))),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 5,
            child: Container(
              decoration: new BoxDecoration(
                image: new DecorationImage(
                    fit: BoxFit.cover,
                    alignment: FractionalOffset.center,
                    image: NetworkImage(insideCoverUrls.elementAt(2))),
              ),
            ),
          ),
        ],
      );
      break;
    case 4:
      return Column(
        children: <Widget>[
          Flexible(
            flex: 5,
            child: Row(
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Container(
                    decoration: new BoxDecoration(
                      image: new DecorationImage(
                          fit: BoxFit.cover,
                          alignment: FractionalOffset.topCenter,
                          image: NetworkImage(insideCoverUrls.elementAt(0))),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    decoration: new BoxDecoration(
                      image: new DecorationImage(
                          fit: BoxFit.cover,
                          alignment: FractionalOffset.topCenter,
                          image: NetworkImage(insideCoverUrls.elementAt(1))),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 5,
            child: Row(
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Container(
                    decoration: new BoxDecoration(
                      image: new DecorationImage(
                          fit: BoxFit.cover,
                          alignment: FractionalOffset.topCenter,
                          image: NetworkImage(insideCoverUrls.elementAt(2))),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    decoration: new BoxDecoration(
                      image: new DecorationImage(
                          fit: BoxFit.cover,
                          alignment: FractionalOffset.topCenter,
                          image: NetworkImage(insideCoverUrls.elementAt(3))),
                    ),
                  ),
                ),
              ],
            ),
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
        new DropdownMenuItem<String>(value: pl.title, child: Text(pl.title));
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
  var dropdownItem = availablePlaylists.elementAt(0).title;
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
    String playlistsInFolder = folder.containedPlaylists.elementAt(0).title;
    for (var i = 1; i < folder.containedPlaylists.length; i++) {
      playlistsInFolder = playlistsInFolder +
          ", " +
          folder.containedPlaylists.elementAt(i).title;
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
                        folder.containedPlaylists.elementAt(i).title)
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
                    playlist.title,
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
                                await deletePlaylistDB(playlist.title);
                            //Borra la referencia local
                            deleteLocalPlaylist(playlist.title);

                            if (deleted) {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                    'Lista de reproducción borrada!',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.grey[700]));
                              // TODO: por ahora lo dejo asi aunque estaria bn buscar una alternativa
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

class PodcastEpisodes extends StatelessWidget {
  final Podcast podcast;

  PodcastEpisodes(this.podcast);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.of(context).pop()),
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
}

class PodcastTile extends StatelessWidget {
  final Podcast podcast;

  PodcastTile(
    this.podcast,
  );
  // Navigator.of(context).push(MaterialPageRoute(
  //           builder: (BuildContext context) => PodcastEpisodes(podcast)));

  @override
  Widget build(BuildContext context) {
    List cover = new List();
    cover.add(podcast.coverUrl);
    return ListTile(
      leading: Container(
        height: MediaQuery.of(context).size.height / 13,
        width: MediaQuery.of(context).size.width / 5.8,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: playListCover(cover),
        ),
      ),
      title: Text(podcast.title),
      subtitle: Text("Podcast"),
    );
  }
}

class PodcastItem extends StatelessWidget {
  final Podcast podcast;

  PodcastItem(
    this.podcast,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => PodcastEpisodes(podcast)));
        },
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 130.0,
              width: 140.0,
              child: Image.network(
                podcast.coverUrl,
                fit: BoxFit.fitHeight,
              ),
            ),
            Padding(padding: EdgeInsets.all(5.0)),
            Text(
              podcast.title,
              style: TextStyle(
                color: Colors.white.withOpacity(1.0),
                fontSize: 15.0,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class UserTile extends StatelessWidget {
  final User user;
  UserTile({@required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      child: ListTile(
        leading: CircleAvatar(
            radius: 30, backgroundImage: NetworkImage(user.photoUrl)),
        title: Text(user.title),
        onTap: () {
          viewingOwnPublicProfile = false;
          previousIndex = homeIndex.value;
          friendUserName = user.title;
          otherUser = user;
          homeIndex.value = 6;
        },
      ),
    );
  }
}

class SongTile extends StatelessWidget {
  final Song song;
  final List<Song> songsList;
  final String songsListName;

  SongTile({
    @required this.song,
    @required this.songsList,
    @required this.songsListName,
  });

  @override
  Widget build(BuildContext context) {
    List songCover = new List();
    songCover.add(song.albumCoverUrls.elementAt(0));
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          setQueue(songsList, song, songsListName);
          onPlayerScreen = true;
          if (player == null) player = PlayerWidget();
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => PlayingNowScreen()));
        },
        child: Column(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height / 7,
              width: 140.0,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: playListCover(songCover)),
            ),
            Padding(padding: EdgeInsets.all(5.0)),
            Text(
              song.title,
              style: TextStyle(
                color: Colors.white.withOpacity(1.0),
                fontSize: 15.0,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PlaylistTile extends StatelessWidget {
  final PlaylistType playlist;
  final bool isOwn;

  PlaylistTile({@required this.playlist, @required this.isOwn});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          currentPlaylist = playlist;
          currentPlaylistInNotOwn = isOwn;
          homeIndex.value = 5;
        },
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 130.0,
              width: 140.0,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: playListCover(playlist.coverUrls)),
            ),
            Padding(padding: EdgeInsets.all(5.0)),
            Text(
              playlist.title,
              style: TextStyle(
                color: Colors.white.withOpacity(1.0),
                fontSize: 15.0,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class GenreTile extends StatelessWidget {
  final Genre genre;

  GenreTile({
    @required this.genre,
  });

  @override
  Widget build(BuildContext context) {
    List genreCover = new List();
    genreCover.add(genre.photoUrl);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          currentGenre = genre;
          previousIndex = homeIndex.value;
          homeIndex.value = 3;
        },
        child: Column(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height / 7,
              width: 140.0,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: playListCover(genreCover)),
            ),
            Padding(padding: EdgeInsets.all(5.0)),
            Text(
              genre.name,
              style: TextStyle(
                color: Colors.white.withOpacity(1.0),
                fontSize: 15.0,
              ),
            )
          ],
        ),
      ),
    );
  }
}
