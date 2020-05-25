import 'package:flutter/material.dart';
import 'package:playstack/models/Audio.dart';
import 'package:playstack/screens/Library/Language.dart';
import 'package:playstack/services/database.dart';

class Podcast {
  String coverUrl;
  String title;
  String desc;
  List hosts = new List();

  Language language;
  List episodes;
  bool isFav = false;
  String url;

  List topics;

  Podcast(
      {@required this.title,
      this.coverUrl,
      this.hosts,
      this.episodes,
      this.url,
      this.desc,
      this.language,
      this.topics,
      this.isFav = false});

  Map getInfo() {
    Map podcastInfo = {
      "title": title,
      "cover": coverUrl,
      "description": desc,
      "episodes": episodes,
      "url": url,
      "isFav": isFav,
      "language": language,
      "hosts": hosts,
      "topics": topics,
    };
    return podcastInfo;
  }

  void setPodcastInfo(String cover, String title, String desc, List hosts,
      Language language, List episodes, String url, List topics) {
    this.coverUrl = cover;
    this.hosts = hosts;
    this.episodes = episodes;
    this.url = url;
    this.desc = desc;
    this.language = language;
    this.topics = topics;
  }

  String getCover() {
    return this.coverUrl;
  }

  Future setAsFav() async {
    bool added = await toggleSubscribe(this.title, true);
    if (added) {
      this.isFav = true;
    }
  }

  Future removeFromFavs() async {
    bool removed = await toggleSubscribe(this.title, false);
    if (removed) {
      this.isFav = false;
    }
  }
}
