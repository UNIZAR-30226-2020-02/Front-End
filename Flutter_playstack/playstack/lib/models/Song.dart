import 'package:flutter/material.dart';
import 'package:playstack/services/database.dart';
import 'package:playstack/shared/common.dart';

class Song {
  String title;
  List artists;
  List albums;
  List genres;
  int duration;
  bool isFav = false;
  String url;
  List albumCoverUrls;

  Song(
      {this.title,
      this.artists,
      this.url,
      this.albums,
      this.albumCoverUrls,
      this.isFav = false});
  /* Song(this.title, this.album, this.artists, this.duration,
      this.isFav, this.url, this.albumCoverUrl); */

  Map getInfo() {
    Map songInfo = {
      "title": title,
      "album": albums,
      "url": url,
      "isFav": isFav,
      "duration": duration,
      "artists": artists,
      "albumCoverUrls": albumCoverUrls
    };
    return songInfo;
  }

  void setInfo(String title, List artists, String url, List albums,
      dynamic albumCovers, List genres) {
    if (albumCovers is String) {
      albumCovers = albumCovers.toList();
    }
    this.title = title;
    this.artists = artists;
    this.url = url;
    this.albums = albums;
    this.albumCoverUrls = albumCovers;
    this.genres = genres;
  }

  String getSongUrl() {
    return this.url;
  }

  String getAlbumCover() {
    return albumCoverUrls.elementAt(0);
  }

  Future setAsFav() async {
    bool added = await toggleFav(this.title, true);
    if (added) {
      this.isFav = true;
    }
  }

  Future removeFromFavs() async {
    bool removed = await toggleFav(this.title, false);
    if (removed) {
      this.isFav = false;
    }
  }

  void markAsListened() async {
    markAsListenedDB(this.title);
  }
}
