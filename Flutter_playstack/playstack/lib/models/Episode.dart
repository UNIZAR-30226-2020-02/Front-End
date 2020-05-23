import 'package:flutter/material.dart';
import 'package:playstack/models/Audio.dart';
import 'package:playstack/models/Podcast.dart';
import 'package:playstack/services/database.dart';
import 'package:playstack/shared/common.dart';

class Episode extends Audio {
  int number;
  String title;
  List artists;
  List topics;
  String date;
  //List topics;
  int duration;
  String url;
  List albumCoverUrls;
  String podcastUrl;

  Episode(
      {this.number,
      this.title,
      this.artists,
      this.url,
      this.topics,
      this.albumCoverUrls,
      this.date,
      this.duration});

  Map getInfo() {
    Map songInfo = {
      "title": title,
      "topics": topics,
      "url": url,
      "duration": duration,
      "artists": artists,
      "albumCoverUrls": albumCoverUrls,
      "date": date,
    };
    return songInfo;
  }

  @override
  void setInfo(String title, List artists, String url, List albums,
      dynamic albumCovers, List genres, bool isFav) {}

  void setEInfo(String title, List artists, String url, List albums,
      dynamic albumCovers, List genres, String date, int duration) {
    if (albumCovers is String) {
      albumCovers = albumCovers.toList();
    }
    this.title = title;
    this.artists = artists;
    this.url = url;
    this.albums = albums;
    this.albumCoverUrls = albumCovers;
    this.genres = genres;
    this.date = date;
    this.duration = duration;
  }

  String getCover() {
    return albumCoverUrls.elementAt(0);
  }
}
