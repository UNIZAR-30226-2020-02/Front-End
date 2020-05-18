import 'package:flutter/material.dart';
import 'package:playstack/services/database.dart';
import 'package:playstack/shared/common.dart';

class Audio {
  String title;
  List artists;
  List albums;
  List genres;
  int duration;
  bool isFav = false;
  String url;
  List albumCoverUrls;
  bool isLocal = false;

  Audio(
      {this.title,
      this.artists,
      this.url,
      this.albumCoverUrls,
      this.isFav = false,
      this.isLocal = false});

  String getAudioUrl() {
    return this.url;
  }

  //TODO: esto hay que mejorarlo
  void setInfo(String title, List artists, String url, List albums,
      dynamic albumCovers, List genres) {}

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
