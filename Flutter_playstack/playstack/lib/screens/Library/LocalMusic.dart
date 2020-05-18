import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:playstack/models/LocalPlaylist.dart';
import 'package:playstack/models/LocalSong.dart';
import 'package:playstack/models/Song.dart';
import 'package:playstack/screens/Player/PlayerWidget.dart';
import 'package:playstack/screens/Player/PlayingNow.dart';
import 'package:playstack/services/SQLite.dart';
import 'package:playstack/shared/common.dart';
import 'package:toast/toast.dart';
import 'package:playstack/models/LocalSongsPlaylists.dart';

class LocalMusic extends StatefulWidget {
  @override
  _LocalMusicState createState() => _LocalMusicState();
}

class _LocalMusicState extends State<LocalMusic> {
  TextEditingController newPLaylistController = new TextEditingController();
  TextEditingController newSongController = new TextEditingController();

  List localPlaylistList = new List();
  List localSongsList = new List();

  bool _loading = true;
  String _path;

  @override
  void initState() {
    super.initState();
    _getPlaylists();
    _getSongs();
  }

  Future<void> _getSongs() async {
    localSongsList = await getLocalSongs();
    List tempList = new List();
    for (var song in localSongsList) {
      Song newSong = new Song(
          title: song.name,
          url: song.path,
          isLocal: true,
          albums: new List(),
          albumCoverUrls: new List());
      tempList.add(newSong);
    }
    localSongsList = tempList;
    print("Hay " + localSongsList.length.toString() + " canciones locales");

    if (mounted)
      setState(() {
        _loading = false;
      });
  }

  void _getPlaylists() async {
    localPlaylistList = await getLocalPlaylists();
    print("Hay " + localPlaylistList.length.toString() + " playlists locales");
    if (mounted)
      setState(() {
        _loading = false;
      });
  }

  void _saveSong() async {
    await _showAddingLocalSongDialog(context);
    String path = await _getFilePath();
    LocalSong newLocalSong =
        new LocalSong(name: newSongController.text, path: path);
    print("Inserting song with name " +
        newSongController.text +
        " and path " +
        path);
    insertSong(newLocalSong);
    newSongController.clear();
    _getSongs();
  }

  Future<String> _getFilePath() async {
    String _path = "";
    try {
      _path = await FilePicker.getFilePath(type: FileType.any);
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    return _path;
  }

  Widget localPlaylists() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: localPlaylistList.isEmpty ? 0 : localPlaylistList.length,
      itemBuilder: (BuildContext context, int index) {
        return localPlaylistTile(localPlaylistList[index]);
      },
    );
  }

  Widget localSongs() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: localSongsList.isEmpty ? 0 : localSongsList.length,
      itemBuilder: (BuildContext context, int index) {
        return localSongItem(
          localSongsList[index],
          localSongsList,
          "Musica local",
        );
      },
    );
  }

  Widget localPlaylistTile(LocalPlaylist playlist) {
    return GestureDetector(
      onTap: () {
        /* 
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => Playlist(playlist))); */
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
                      child: Image.asset("assets/images/defaultCover.png"),
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
                        Toast.show('Borrando lista de reproducción...', context,
                            gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
                        int deleted = await deleteLocalPlaylist(playlist.name);
                        if (deleted > 0) {
                          Toast.show('Lista de reproducción borrada!', context,
                              gravity: Toast.CENTER,
                              duration: Toast.LENGTH_LONG,
                              backgroundColor: Colors.green);
                          _getPlaylists();
                          if (mounted) setState(() {});
                        } else {
                          Toast.show(
                              'No se pudo borrar la lista de reproducción',
                              context,
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

  List<DropdownMenuItem> _listLocalPlaylistNames() {
    List<DropdownMenuItem> items = new List();
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
                              onPressed: () {
                                LocalSongsPlaylists newEntry =
                                    new LocalSongsPlaylists(
                                        id: "$songName$dropdownItem",
                                        songName: songName,
                                        playlistName: dropdownItem);
                                insertSongToPlaylist(newEntry);
                                Toast.show("msg", context);
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

  Widget localSongItem(Song song, List songsList, String songsListName) {
    /* final String songsListName;
  final List songsList;
  final Song song;
  final PlaylistType playlist;
  final bool isNotOwn;
 */

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
                        int removed = await deleteLocalSong(song.title);
                        if (removed > 0) {
                          Toast.show(
                              'Canción eliminada de la aplicación', context,
                              gravity: Toast.CENTER,
                              duration: Toast.LENGTH_LONG,
                              backgroundColor: Colors.green);
                          await _getSongs();
                          setState(() {});
                        } else {
                          Toast.show('Error eliminando canción', context,
                              gravity: Toast.CENTER,
                              duration: Toast.LENGTH_LONG,
                              backgroundColor: Colors.red);
                        }
                        break;

                      case "AddToPlaylist":
                        _showAddingSongToPlaylistDialog(song.title, context);
                        break;
                      case "removeFromPlaylist":
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
                        /*
                           PopupMenuItem(
                                value: "removeFromPlaylist",
                                child: ListTile(
                                  leading: Icon(CupertinoIcons.delete),
                                  title: Text("Eliminar canción de lista"),
                                )) */
                      ])
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddingLocalSongDialog(BuildContext context) {
    bool _validate = false;
    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text("Añadiendo cancion local"),
            elevation: 100.0,
            backgroundColor: Colors.grey[900],
            actions: <Widget>[
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: TextField(
                    controller: newSongController,
                    decoration: InputDecoration(
                        hintText: "Nombre cancion",
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
                                if (newSongController.text.isEmpty) {
                                  _validate = true;
                                } else {
                                  _validate = false;
                                  Navigator.pop(context);
                                }
                              });
                            },
                            child: Text("Crear")))
                  ],
                ),
              )
            ],
          );
        });
      },
    );
  }

  Future<void> _showCreatingPlaylistDialog(BuildContext context) {
    bool _validate = false;
    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text("Crear lista de reproducción local"),
            elevation: 100.0,
            backgroundColor: Colors.grey[900],
            actions: <Widget>[
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: TextField(
                    controller: newPLaylistController,
                    decoration: InputDecoration(
                        hintText: "Nombre lista",
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
                            onPressed: () {
                              newPLaylistController.clear();
                              Navigator.pop(context);
                            },
                            child: Text("Cancelar"))),
                    Expanded(
                        flex: 1,
                        child: FlatButton(
                            onPressed: () {
                              setState(() {
                                if (newPLaylistController.text.isEmpty) {
                                  _validate = true;
                                } else {
                                  _validate = false;
                                  LocalPlaylist newLocalPlaylist =
                                      new LocalPlaylist(
                                          name: newPLaylistController.text);
                                  insertPlaylist(newLocalPlaylist);
                                  newPLaylistController.clear();
                                  Navigator.pop(context);
                                }
                              });
                            },
                            child: Text("Crear")))
                  ],
                ),
              )
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("Música local del dispositivo"),
        ),
        body: ListView(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25.0),
                          child: Text(
                            "Listas de reproduccion",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      Expanded(
                          flex: 1,
                          child: IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () async {
                                await _showCreatingPlaylistDialog(context);
                                _getPlaylists();
                              }))
                    ],
                  ),
                  localPlaylistList.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: localPlaylists(),
                        )
                      : Text('')
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 25.0),
                            child: Text("Canciones locales",
                                style: TextStyle(fontSize: 18)),
                          )),
                      Expanded(
                          flex: 1,
                          child: IconButton(
                              icon: Icon(Icons.add), onPressed: _saveSong))
                    ],
                  ),
                  localSongsList.isNotEmpty ? localSongs() : Text("")
                ],
              ),
            ),
            FlatButton(
                color: Colors.red,
                onPressed: () async {
                  await dropAndCreate();
                  _getSongs();
                },
                child: Text("Drop"))
          ],
        ));
  }
}
