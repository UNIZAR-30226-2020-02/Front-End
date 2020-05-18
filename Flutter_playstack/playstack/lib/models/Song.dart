import 'package:flutter/material.dart';
import 'package:playstack/models/Audio.dart';
import 'package:playstack/services/database.dart';
import 'package:playstack/shared/common.dart';

class Song extends Audio {
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

  @override
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

  String getCover() {
    return albumCoverUrls.elementAt(0);
  }
}
