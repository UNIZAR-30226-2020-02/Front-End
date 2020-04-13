import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Library extends StatefulWidget {
  @override
  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  Widget musicTab() {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Color(0xFF191414),
          appBar: AppBar(
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

  Widget playLists() {
    return ListView(
      physics: BouncingScrollPhysics(),
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.add),
          title: Text(
            'Nueva lista de reproducción',
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500),
          ),
          onTap: null,
        ),
        ListTile(
          leading: Icon(Icons.favorite, color: Colors.red),
          title: Text('Favoritas'),
          subtitle: Text('Canciones favoritas'),
          onTap: null,
        ),
        ListTile(
          leading: Icon(
            Icons.archive,
          ),
          title: Text('Música del dispositivo'),
          subtitle: Text('Música local'),
          onTap: null,
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
