import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playstack/shared/common.dart';

class UpNext extends StatefulWidget {
  @override
  _UpNextState createState() => _UpNextState();
}

class _UpNextState extends State<UpNext> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          songsNextUpName,
          style: TextStyle(fontFamily: 'Circular', fontSize: 25),
        ),
        centerTitle: true,
        leading: IconButton(
            iconSize: 35,
            icon: Icon(CupertinoIcons.clear),
            onPressed: () => Navigator.of(context).pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 5, 0),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                'Reproduciendo ahora',
                style: TextStyle(fontSize: 20, fontFamily: 'Circular'),
              ),
            ),
            GenericAudioItem(currentAudio),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Text("A continuación en $songsNextUpName",
                  style: TextStyle(fontSize: 20, fontFamily: 'Circular')),
            ),
            ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: songsNextUp.isEmpty ? 0 : songsNextUp.length,
              itemBuilder: (BuildContext context, int index) {
                return new GenericAudioItem(songsNextUp[index]);
              },
            )
          ],
        ),
      ),
    );
  }
}
