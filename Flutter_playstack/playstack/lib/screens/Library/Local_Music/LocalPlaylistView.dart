import 'package:flutter/cupertino.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:playstack/models/LocalPlaylist.dart';
import 'package:playstack/models/LocalSongsPlaylists.dart';
import 'package:playstack/models/Song.dart';
import 'package:playstack/services/SQLite.dart';
import 'package:playstack/shared/Loading.dart';
import 'package:playstack/shared/common.dart';
import 'package:toast/toast.dart';

class LocalPlaylistView extends StatefulWidget {
  final String playlistName;
  LocalPlaylistView(this.playlistName);
  @override
  _LocalPlaylistViewState createState() =>
      _LocalPlaylistViewState(playlistName);
}

class _LocalPlaylistViewState extends State<LocalPlaylistView> {
  String playlistName;
  // Contiene los nombres de las canciones de la playlist
  List<Song> songs = new List();
  bool _loading = true;

  _LocalPlaylistViewState(this.playlistName);

  final TextEditingController _playlistNameController =
      new TextEditingController();

  @override
  void initState() {
    super.initState();
    _getSongs();
  }

  void _getSongs() async {
    List<LocalSongsPlaylists> _tempList = await getSongsInPlaylists();
    songs.clear();
    for (var item in _tempList) {
      if (item.playlistName == playlistName) {
        Song newSong = new Song(title: item.songName, isLocal: true);
        songs.add(newSong);
      }
    }
    print("Hay ${songs.length.toString()} canciones en la playlist");
    if (mounted)
      setState(() {
        _loading = false;
      });
  }

  void changePlaylistName() async {
    Toast.show("Actualizando...", context, gravity: Toast.TOP);
    LocalPlaylist tempPlaylist =
        new LocalPlaylist(name: _playlistNameController.text);

    int result = await updateLocalPlaylist(tempPlaylist, playlistName);
    result += await updateLocalPlaylistSongsRelation(
        playlistName, _playlistNameController.text);

    if (result > 0) {
      Toast.show('Lista de reproducción actualizada!', context,
          gravity: Toast.CENTER,
          duration: Toast.LENGTH_LONG,
          backgroundColor: Colors.green);
      playlistName = _playlistNameController.text;
    } else {
      Toast.show('Error actualizando lista de reproducción', context,
          gravity: Toast.CENTER,
          duration: Toast.LENGTH_LONG,
          backgroundColor: Colors.red);
    }
    setState(() {
      _playlistNameController.clear();
    });
  }

  Future<void> _showEditPlaylistDialog(BuildContext context) {
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
                    controller: _playlistNameController,
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
                                if (_playlistNameController.text.isEmpty) {
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
              _showEditPlaylistDialog(context);
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
    return _loading
        ? Loading()
        : Container(
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
                  playlistName,
                  style: TextStyle(fontSize: 25, fontFamily: 'Circular'),
                ),
                backgroundColor: Colors.transparent,
                leading: IconButton(
                    icon: Icon(CupertinoIcons.back),
                    onPressed: () => Navigator.of(context).pop()),
              ),
              bottomNavigationBar: bottomBar(context),
              backgroundColor: Colors.transparent,
              body: ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 4,
                            width: MediaQuery.of(context).size.width / 2,
                            child: Image.asset(
                              defaultCover,
                              fit: BoxFit.cover,
                            )),
                        BackdropFilter(
                          filter:
                              ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
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
                            child: Image.asset(defaultCover))
                      ],
                    ),
                  ),
                  // Lista el nombre de la playlist
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 15, 0, 5),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(flex: 1, child: playlistOptionsButton()),
                          Expanded(
                              flex: 2,
                              child:
                                  shuffleButton(playlistName, songs, context)),
                          Expanded(flex: 1, child: Text(''))
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
                          itemCount: songs.isEmpty ? 0 : songs.length,
                          itemBuilder: (BuildContext context, int index) {
                            return LocalSongItem(
                              songs[index],
                              songs,
                              playlistName,
                              playlistName: playlistName,
                              onDeletedCallBack: () {
                                print("Hace el callback");
                                _getSongs();
                              },
                            );
                          },
                        )
                ],
              ),
            ));
  }
}
