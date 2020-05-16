import 'package:flutter/material.dart';

class LocalMusic extends StatefulWidget {
  @override
  _LocalMusicState createState() => _LocalMusicState();
}

class _LocalMusicState extends State<LocalMusic> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Música del dispositivo"),
      ),
    );
  }
}
