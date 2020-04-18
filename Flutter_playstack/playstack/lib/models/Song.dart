import 'package:flutter/material.dart';
import 'package:playstack/services/database.dart';

class Song {
  int id = 0;
  List artists;
  String title;
  List albunes;
  int duration;
  bool isFav = false;
  String url;
  String albumCoverUrl;

  Song(this.title, this.artists, this.url, this.albunes, this.albumCoverUrl);
  /* Song(this.title, this.album, this.artists, this.duration,
      this.isFav, this.url, this.albumCoverUrl); */

  Map getInfo() {
    Map songInfo = {
      "title": title,
      "album": albunes,
      "url": url,
      "isFav": isFav,
      "duration": duration,
      "artists": artists,
      "albumCoverUrl": albumCoverUrl
    };
    return songInfo;
  }

  String getSongUrl() {
    return this.url;
  }

  String getAlbumCover() {
    return albumCoverUrl;
  }

  void setAsFav() async {
    bool added = await setAsFavDB(this.title);
    if (added) {
      this.isFav = true;
    }
  }

  void removeFromFavs() {
    this.isFav = false;
    //TODO: Base de datos
  }

  void markAsListened() async {
    markAsListenedDB(this.title);
  }
}
