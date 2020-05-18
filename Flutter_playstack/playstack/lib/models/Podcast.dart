import 'package:playstack/models/Audio.dart';
import 'package:playstack/screens/Library/Language.dart';

class Podcast {
  String coverUrl;
  String title;
  String desc;
  List hosts;

  Language language;
  List episodes;
  bool isFav = false;
  String url;

  List topics;

  Podcast(
      {this.title,
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

  Future subscribe() async {
    return true;
  }

  Future unsubscribe() async {
    return true;
  }
}
