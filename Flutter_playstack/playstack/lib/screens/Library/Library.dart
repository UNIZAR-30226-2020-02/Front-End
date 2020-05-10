import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playstack/models/PlaylistType.dart';
import 'package:playstack/screens/Library/Playlist.dart';
import 'package:playstack/services/database.dart';
import 'package:playstack/shared/Loading.dart';
import 'package:playstack/shared/common.dart';
import 'package:toast/toast.dart';

class Library extends StatefulWidget {
  @override
  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  final TextEditingController newPLaylistController =
      new TextEditingController();
  final TextEditingController newFolderController = new TextEditingController();
  List folders = new List();
  bool _loading = true;
  String dropdownItem;
  @override
  void initState() {
    super.initState();
    getFolders();
    getPlaylists();
  }

  void getFolders() async {
    folders = await getUserFolders();
    setState(() {
      _loading = false;
    });
  }

  void getPlaylists() async {
    playlists = await getUserPlaylists();
    setState(() {
      _loading = false;
    });
  }

  Widget musicTab() {
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
            children: [playLists(), Text('artistas'), Text('albumes')],
          ),
        ));
  }

  void createPlaylist(bool isPrivate) async {
    Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
          'Creando lista de reproducción...',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[700]));
    var result = await createPlaylistDB(newPLaylistController.text, isPrivate);

    if (result) {
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(
            '¡Lista de reproducción creada!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.grey[700]));
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
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
        content: Text(
          'Creando carpeta...',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[700]));
    var result = await createFolderDB(newFolderController.text, dropdownItem);

    if (result) {
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(
            '¡Carpeta creada!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.grey[700]));
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
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
    dropdownItem = playlists.elementAt(0).name;
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
          onTap: null,
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
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  Playlist(new PlaylistType(name: "Favoritas")))),
        ),
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
                    return new FolderItem(folders[index]);
                  } else {
                    return new PlaylistItem(
                        playlists[index - folders.length], false);
                  }
                },
              )
      ],
    );
  }

  Widget podcastsTab() {
    return Center(child: Text("Podcasts"));
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
