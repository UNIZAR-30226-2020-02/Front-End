import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playstack/screens/Library/Playlist.dart';
import 'package:playstack/services/database.dart';
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
  List playlists = new List();

  @override
  void initState() {
    super.initState();
    getPlaylists();
  }

  void getPlaylists() async {
    playlists = await getUserPlaylists();
    setState(() {});
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
    setState(() {});
  }

  void createFolder() async {
    Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
          'Creando carpeta...',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[700]));
    var result = await createFolderDB(newFolderController.text);

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
    setState(() {});
  }

  Future<void> showCreatingFolderDialog(BuildContext context) {
    String dropdownValue;
    bool _validate = false;
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
          leading: Icon(CupertinoIcons.add_circled),
          title: Text(
            'Nueva carpeta',
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500),
          ),
          onTap: () {
            showCreatingFolderDialog(context);
          },
        ),
        ListTile(
          leading: Icon(CupertinoIcons.add),
          title: Text(
            'Nueva lista de reproducción',
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500),
          ),
          onTap: () => showCreatingPlaylistDialog(context),
        ),
        ListTile(
          leading: Icon(CupertinoIcons.heart_solid, color: Colors.red),
          title: Text('Favoritas'),
          subtitle: Text('Canciones favoritas'),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => Playlist('Favoritas'))),
        ),
        ListTile(
          leading: Icon(
            Icons.archive,
          ),
          title: Text('Música del dispositivo'),
          subtitle: Text('Música local'),
          onTap: null,
        ),
        ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: playlists.isEmpty ? 0 : playlists.length,
          itemBuilder: (BuildContext context, int index) {
            return new PlaylistItem(playlists[index]);
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
