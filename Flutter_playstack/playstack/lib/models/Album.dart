import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playstack/screens/Library/AlbumSongs.dart';
import 'package:playstack/shared/common.dart';

class Album {
  final String name;
  final String coverUrl;

  Album(this.name, this.coverUrl);
}

class AlbumTile extends StatelessWidget {
  final Album album;
  AlbumTile(this.album);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(album.name),
        subtitle: Text("Album"),
        leading: Container(
          height: MediaQuery.of(context).size.height / 12,
          width: MediaQuery.of(context).size.width / 5.8,
          child: ClipRRect(
            child: Image.network(
              album.coverUrl,
              fit: BoxFit.fill,
            ),
          ),
        ),
        onTap: () {
          leftAlready = false;
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => AlbumSongs(album)));
        },
      ),
    );
  }
}
