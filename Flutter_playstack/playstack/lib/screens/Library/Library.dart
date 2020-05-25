import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playstack/models/Album.dart';
import 'package:playstack/models/Artist.dart';
import 'package:playstack/models/LocalPlaylist.dart';
import 'package:playstack/models/PlaylistType.dart';
import 'package:playstack/screens/Homescreen/ArtistProfile.dart';
import 'package:playstack/screens/Library/Folder.dart';
import 'package:playstack/screens/Library/Local_Music/LocalMusic.dart';
import 'package:playstack/screens/Library/Playlist.dart';
import 'package:playstack/screens/Library/PodcastWidgets.dart';
import 'package:playstack/services/database.dart';
import 'package:playstack/shared/Loading.dart';
import 'package:playstack/shared/common.dart';
import 'package:toast/toast.dart';
import 'package:playstack/services/SQLite.dart';

class Library extends StatefulWidget {
  @override
  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends State<Library> with TickerProviderStateMixin {
  final TextEditingController newPLaylistController =
      new TextEditingController();
  final TextEditingController newFolderController = new TextEditingController();

  List folders = new List();
  List artistsList = new List();
  List albumsList = new List();

  bool _loading = true;
  bool _loadingArtists = true;
  bool _loadingAlbums = true;

  String dropdownItem;

  @override
  void initState() {
    super.initState();
    getFolders();
    getPlaylists();
    getArtists();
    getAlbums();
  }

  void getAlbums() async {
    albumsList = await getAlbumsDB();
    if (currentIndex.value == 2) {
      if (mounted)
        setState(() {
          _loadingAlbums = false;
        });
    }
  }

  void getArtists() async {
    artistsList = await getAllArtistsDB();
    if (currentIndex.value == 2) {
      if (mounted)
        setState(() {
          _loadingArtists = false;
        });
    }
  }

  void getFolders() async {
    folders = await getUserFolders();

    if (currentIndex.value == 2) {
      if (mounted)
        setState(() {
          _loading = false;
        });
    }
  }

  void getPlaylists() async {
    playlists = await getUserPlaylists();
    if (currentIndex.value == 2) {
      if (mounted)
        setState(() {
          _loading = false;
        });
    }
  }

  Widget musicTab() {
    return ValueListenableBuilder(
        valueListenable: musicIndex,
        builder: (BuildContext context, int value, Widget child) {
          return WillPopScope(
              onWillPop: () async {
                currentIndex.value = 0;
                return false;
              },
              child: showMusic(musicIndex.value));
        });
  }

  Widget showMusic(int index) {
    print("Showmusic con numero ${index.toString()}");
    Widget result;
    switch (index) {
      case 0:
        result = mainMusic();
        break;
      case 1:
        result = Playlist(currentPlaylist);
        break;
      case 2:
        result = Folder(currentFolder);
        break;
      case 3:
        result = Playlist(
          currentPlaylist,
          isNotOwn: currentPlaylistInNotOwn,
        );
        break;
      case 4:
        result = ArtistProfile(currentArtist);
        break;
      default:
    }
    return result;
  }

  Widget mainMusic() {
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
                  tabs: [
                    Tab(
                      child: Text(
                        'Playlists',
                        style: TextStyle(fontFamily: 'Circular', fontSize: 15),
                      ),
                    ),
                    Tab(
                      child: Text(
                        'Artistas',
                        style: TextStyle(fontFamily: 'Circular', fontSize: 15),
                      ),
                    ),
                    Tab(
                      child: Text(
                        'Albumes',
                        style: TextStyle(fontFamily: 'Circular', fontSize: 15),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          body: TabBarView(
            children: [playLists(), artists(), albums()],
          ),
        ));
  }

  void createPlaylist(bool isPrivate) async {
    Scaffold.of(context).showSnackBar(SnackBar(
        duration: new Duration(seconds: 1),
        content: Text(
          'Creando lista de reproducción...',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[700]));
    var result = await createPlaylistDB(newPLaylistController.text, isPrivate);

    if (result) {
      Scaffold.of(context).showSnackBar(SnackBar(
          duration: new Duration(seconds: 1),
          content: Text(
            '¡Lista de reproducción creada!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.grey[700]));
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
          duration: new Duration(seconds: 1),
          content: Text(
            'No se pudo crear la lista de reproducción',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.grey[700]));
    }
    newPLaylistController.clear();
    getPlaylists();
  }

  void createFolder() async {
    Scaffold.of(context).showSnackBar(SnackBar(
        duration: new Duration(seconds: 1),
        content: Text(
          'Creando carpeta...',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[700]));
    var result = await createFolderDB(newFolderController.text, dropdownItem);

    if (result) {
      Scaffold.of(context).showSnackBar(SnackBar(
          duration: new Duration(seconds: 1),
          content: Text(
            '¡Carpeta creada!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.grey[700]));
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
          duration: new Duration(seconds: 1),
          content: Text(
            'No se pudo crear la carpeta',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.grey[700]));
    }
    newFolderController.clear();
    getFolders();
  }

  Future<void> showCreatingFolderDialog(BuildContext context) {
    bool _validate = false;
    dropdownItem = playlists.elementAt(0).title;
    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text("Crear carpeta"),
            elevation: 100.0,
            backgroundColor: Colors.grey[900],
            actions: <Widget>[
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: TextField(
                    controller: newFolderController,
                    decoration: InputDecoration(
                        hintText: "Nombre carpeta",
                        errorText:
                            _validate ? 'Introduzca un nombre válido' : null),
                  )),
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
                                if (newFolderController.text.isEmpty) {
                                  _validate = true;
                                } else {
                                  _validate = false;
                                  Navigator.pop(context);
                                  createFolder();
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

  Future<void> showCreatingPlaylistDialog(BuildContext context) {
    bool _isPrivate = false;
    bool _validate = false;
    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text("Crear lista de reproducción"),
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
                child: CheckboxListTile(
                  activeColor: Colors.amber,
                  value: _isPrivate,
                  onChanged: (newVal) {
                    setState(() {
                      _isPrivate = !_isPrivate;
                    });
                  },
                  title: Text("¿Hacer playlist privada?"),
                ),
              ),
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
                                if (newPLaylistController.text.isEmpty) {
                                  _validate = true;
                                } else {
                                  _validate = false;
                                  Navigator.pop(context);
                                  createPlaylist(_isPrivate);
                                  if (accountType == "Premium") {
                                    LocalPlaylist newLocalPlaylist =
                                        new LocalPlaylist(
                                            name: newPLaylistController.text);
                                    insertPlaylist(newLocalPlaylist);
                                  }
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

  Widget albums() {
    return _loadingAlbums
        ? LoadingSongs()
        : ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: albumsList.isEmpty ? 0 : albumsList.length,
            itemBuilder: (BuildContext context, int index) {
              return new AlbumTile(albumsList[index]);
            },
          );
  }

  Widget artists() {
    return _loadingArtists
        ? LoadingSongs()
        : ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: artistsList.isEmpty ? 0 : artistsList.length,
            itemBuilder: (BuildContext context, int index) {
              return new ArtistTile(artistsList[index]);
            },
          );
  }

  Widget playLists() {
    return ListView(
      physics: BouncingScrollPhysics(),
      children: <Widget>[
        ListTile(
          leading: Container(
            height: MediaQuery.of(context).size.height / 13,
            width: MediaQuery.of(context).size.width / 6.5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Icon(CupertinoIcons.add_circled, size: 30),
            ),
          ),
          title: Text(
            'Nueva carpeta',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
          ),
          onTap: () {
            playlists.length > 0
                ? showCreatingFolderDialog(context)
                : Toast.show(
                    "Necesitas tener alguna playlist para poder crear carpetas",
                    context,
                    gravity: Toast.CENTER);
          },
        ),
        ListTile(
          leading: Container(
            height: MediaQuery.of(context).size.height / 13,
            width: MediaQuery.of(context).size.width / 6.5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Icon(CupertinoIcons.add, size: 30),
            ),
          ),
          title: Text(
            'Nueva lista de reproducción',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
          ),
          onTap: () => showCreatingPlaylistDialog(context),
        ),
        ListTile(
          leading: Container(
            height: MediaQuery.of(context).size.height / 13,
            width: MediaQuery.of(context).size.width / 6.5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Icon(
                Icons.archive,
              ),
            ),
          ),
          title: Text('Música del dispositivo',
              style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500)),
          subtitle: Text('Música local'),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => LocalMusic())),
        ),
        ListTile(
            leading: Container(
              height: MediaQuery.of(context).size.height / 13,
              width: MediaQuery.of(context).size.width / 6.5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  'assets/images/Favs_cover.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Text('Favoritas',
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500)),
            subtitle: Text('Canciones favoritas'),
            onTap: () {
              previousIndex = musicIndex.value;
              currentPlaylist = new PlaylistType(title: "Favoritas");
              musicIndex.value = 1; // Playlist
            }),
        _loading
            ? LoadingSongs()
            : ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: (playlists.length + folders.length) < 1
                    ? 0
                    : (playlists.length + folders.length),
                itemBuilder: (BuildContext context, int index) {
                  if (index < folders.length) {
                    return new FolderItem(folders[index],
                        onUpdatedCallBack: () {
                      getFolders();
                    });
                  } else {
                    return new PlaylistItem(
                      playlists[index - folders.length],
                      false,
                      onChangedCallback: () => getPlaylists(),
                    );
                  }
                },
              )
      ],
    );
  }

  Widget podcastsTab() {
    return PodcastsTab();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
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
                  tabs: [
                    Tab(
                      child: Text(
                        'Música',
                        style: TextStyle(fontFamily: 'Circular', fontSize: 20),
                      ),
                    ),
                    Tab(
                      child: Text(
                        'Podcasts',
                        style: TextStyle(fontFamily: 'Circular', fontSize: 20),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          body: TabBarView(
            children: [
              musicTab(),
              podcastsTab(),
            ],
          ),
        ));
  }
}
