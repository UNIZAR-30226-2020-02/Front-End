import 'package:flutter/material.dart';

class Library extends StatefulWidget {
  @override
  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  Widget musicTab() {
    return Center(child: Text("Music"));
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
                        'Music',
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
