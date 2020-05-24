import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:playstack/models/LocalSongsPlaylists.dart';
import 'package:playstack/models/PlaylistType.dart';
import 'package:playstack/models/Song.dart';
import 'package:playstack/services/database.dart';
import 'package:playstack/shared/Loading.dart';
import 'package:playstack/shared/common.dart';
import 'dart:ui' as ui;
import 'package:playstack/services/SQLite.dart';

import 'package:toast/toast.dart';

class Playlist extends StatefulWidget {
  final PlaylistType playlist;
  final bool isNotOwn;
  Playlist(this.playlist, {this.isNotOwn});

  @override
  _PlaylistState createState() => _PlaylistState(playlist, isNotOwn);
}

class _PlaylistState extends State<Playlist> {
  final PlaylistType playlist;
  bool isNotOwn;
  final TextEditingController playlistNameController =
      new TextEditingController();

  List songs = new List();
  List localSongs = new List();
  bool _loading = true;

  _PlaylistState(this.playlist, this.isNotOwn);

  @override
  void initState() {
    super.initState();
    if (isNotOwn == null) {
      isNotOwn = false;
    }
    getSongs();
  }

  void getSongs() async {
    if (playlist.title == "Favoritas") {
      songs = await getFavoriteSongs();
    } else {
      isNotOwn
          ? songs = await getPlaylistSongsDB(playlist.title, isNotOwn: true)
          : songs = await getPlaylistSongsDB(playlist.title);
    }

    if (accountType == "Premium") {
      List<LocalSongsPlaylists> _tempList = await getSongsInPlaylists();
      localSongs.clear();
      for (var item in _tempList) {
        if (item.playlistName == playlist.title) {
          Song newSong = new Song(title: item.songName, isLocal: true);
          localSongs.add(newSong);
        }
      }
      print(
          "Hay ${localSongs.length.toString()} canciones en la playlist local");
    }
    if (mounted)
      setState(() {
        _loading = false;
      });
  }

  Widget playlistStatusSwitch() {
    return Column(
      children: <Widget>[
        Switch(
            activeColor: Colors.red[900],
            inactiveThumbColor: Colors.red[500],
            value: playlist.isPrivate ? true : false,
            onChanged: (val) async {
              await playlist.changePlaylistStatus();
              setState(() {});
            }),
        Text(playlist.isPrivate ? "Privada" : "Pública")
      ],
    );
  }

  void changePlaylistName() async {
    Toast.show("Actualizando...", context, gravity: Toast.TOP);
    bool result =
        await playlist.changePlaylistName(playlistNameController.text);

    if (result) {
      setState(() {});
    }
    playlistNameController.clear();
  }

  Future<void> showEditPlaylistDialog(BuildContext context) {
    bool _validate = false;

    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text("Editar lista de reproducción"),
            elevation: 100.0,
            backgroundColor: Colors.grey[900],
            actions: <Widget>[
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: TextField(
                    controller: playlistNameController,
                    decoration: InputDecoration(
                        hintText: "Nuevo Nombre lista",
                        errorText:
                            _validate ? 'Introduzca un nombre válido' : null),
                  )),
              Container(
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
                              setState(() {
                                if (playlistNameController.text.isEmpty) {
                                  _validate = true;
                                } else {
                                  _validate = false;
                                  Navigator.pop(context);
                                  changePlaylistName();
                                }
                              });
                            },
                            child: Text("Aplicar")))
                  ],
                ),
              )
            ],
          );
        });
      },
    );
  }

  Widget playlistOptionsButton() {
    return PopupMenuButton<String>(
        icon: Icon(Icons.more_vert),
        color: Colors.grey[800],
        onSelected: (val) async {
          switch (val) {
            case "Edit":
              showEditPlaylistDialog(context);
              break;
            default:
          }
        },
        itemBuilder: (context) => [
              PopupMenuItem(
                  value: "Edit",
                  child: ListTile(
                    leading: Icon(CupertinoIcons.pencil),
                    title: Text(languageStrings['editPlaylist']),
                  ))
            ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.red[900].withOpacity(0.7),
            Color(0xFF191414),
            Color(0xFF191414),
            Color(0xFF191414),
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              playlist.title,
              style: TextStyle(fontSize: 25, fontFamily: 'Circular'),
            ),
            backgroundColor: Colors.transparent,
            leading: IconButton(
                icon: Icon(CupertinoIcons.back),
                onPressed: () {
                  // Search screen
                  if (currentIndex.value == 1)
                    searchIndex.value = 0;
                  else if (currentIndex.value == 2) // Library
                    musicIndex.value = previousIndex;
                }),
          ),
          //bottomNavigationBar: bottomBar(context),
          backgroundColor: Colors.transparent,
          body: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    playlist.title == "Favoritas"
                        ? SizedBox(
                            height: MediaQuery.of(context).size.height / 4,
                            width: MediaQuery.of(context).size.width / 2,
                            child: Image.asset(
                              "assets/images/Favs_cover.jpg",
                              fit: BoxFit.cover,
                            ))
                        : SizedBox(
                            height: MediaQuery.of(context).size.height / 4,
                            width: MediaQuery.of(context).size.width / 2,
                            child: playListCover(playlist.coverUrls)),
                    BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        height: MediaQuery.of(context).size.height / 4,
                        width: MediaQuery.of(context).size.width,
                        decoration: new BoxDecoration(
                            color: backgroundColor.withOpacity(0.3)),
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height / 4,
                        width: MediaQuery.of(context).size.width / 2,
                        child: playlist.title == "Favoritas"
                            ? Image.asset("assets/images/Favs_cover.jpg")
                            : playListCover(playlist.coverUrls)),
                  ],
                ),
              ),
              // Lista el nombre de la playlist
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 5),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                          flex: 1,
                          child: isNotOwn ? Text('') : playlistOptionsButton()),
                      Expanded(
                          flex: 2,
                          child: shuffleButton(playlist.title, songs, context)),
                      Expanded(
                          flex: 1,
                          child: playlist.title == "Favoritas" || isNotOwn
                              ? Text('')
                              : playlistStatusSwitch())
                    ],
                  ),
                ),
              ),
              playlistsDivider(),
              _loading
                  ? LoadingSongs()
                  : ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: (songs.isEmpty && localSongs.isEmpty)
                          ? 0
                          : (songs.length + localSongs.length),
                      itemBuilder: (BuildContext context, int index) {
                        if (index < songs.length) {
                          if (playlist.title == "Favoritas")
                            return new SongItem(
                              songs[index],
                              songs,
                              playlist.title,
                              playlist: playlist,
                              isNotOwn: isNotOwn,
                              onChangedCallback: () => getSongs(),
                            );
                          else
                            return new SongItem(
                              songs[index],
                              songs,
                              playlist.title,
                              playlist: playlist,
                              isNotOwn: isNotOwn,
                              onChangedCallback: () => getSongs(),
                            );
                        } else {
                          return new LocalSongItem(
                            localSongs[index - songs.length],
                            songs,
                            playlist.title,
                            playlistName: playlist.title,
                            onDeletedCallBack: () {
                              getSongs();
                            },
                          );
                        }
                      },
                    )
            ],
          ),
        ));
  }
}
