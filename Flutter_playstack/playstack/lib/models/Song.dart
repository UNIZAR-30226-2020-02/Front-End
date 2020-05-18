import 'package:flutter/material.dart';
import 'package:playstack/services/database.dart';
import 'package:playstack/shared/common.dart';

class Song {
  String title;
  List artists = new List();
  List albums;
  List genres;
  int duration;
  bool isFav = false;
  bool isLocal = false;
  String url;
  List albumCoverUrls = new List();

  Song(
      {this.title,
      this.artists,
      this.url,
      this.albums,
      this.albumCoverUrls,
      this.isFav = false,
      this.isLocal = false,
      bool isNotOwn});

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
    if (!isLocal)
      return albumCoverUrls.elementAt(0);
    else
      return "assets/image/defaultCover.png";
  }

  Future setAsFav() async {
    if (!isLocal) {
      bool added = await toggleFav(this.title, true);
      if (added) {
        this.isFav = true;
      }
    }
  }

  Future removeFromFavs() async {
    if (!isLocal) {
      bool removed = await toggleFav(this.title, false);
      if (removed) {
        this.isFav = false;
      }
    }
  }

  void markAsListened() async {
    if (!isLocal) markAsListenedDB(this.title);
  }
}
