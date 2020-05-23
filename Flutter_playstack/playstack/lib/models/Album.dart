import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playstack/screens/Library/AlbumSongs.dart';
import 'package:playstack/shared/common.dart';

class Album {
  final String title;
  final String coverUrl;

  Album(this.title, this.coverUrl);
}

class AlbumTile extends StatelessWidget {
  final Album album;
  AlbumTile(this.album);
  @override
  Widget build(BuildContext context) {
    List cover = new List();
    cover.add(album.coverUrl);
    return ListTile(
      title: Text(album.title),
      subtitle: Text("Album"),
      leading: Container(
        height: MediaQuery.of(context).size.height / 13,
        width: MediaQuery.of(context).size.width / 5.8,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: playListCover(cover),
        ),
      ),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => AlbumSongs(album)));
      },
    );
  }
}
