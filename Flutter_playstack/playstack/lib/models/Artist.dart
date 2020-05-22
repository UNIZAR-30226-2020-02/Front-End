import 'package:flutter/material.dart';
import 'package:playstack/screens/Homescreen/ArtistProfile.dart';
import 'package:playstack/shared/common.dart';

class Artist {
  String title;
  String photo;
  Artist(this.title, this.photo);
}

class ArtistTile extends StatelessWidget {
  final Artist artist;
  ArtistTile(this.artist);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(artist.title),
        leading: CircleAvatar(
            radius: 30, backgroundImage: NetworkImage(artist.photo)),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => ArtistProfile(artist))),
      ),
    );
  }
}

class ArtistTileList extends StatelessWidget {
  final Artist artist;

  ArtistTileList(
    this.artist,
  );
  // Navigator.of(context).push(MaterialPageRoute(
  //           builder: (BuildContext context) => PodcastEpisodes(podcast)));

  @override
  Widget build(BuildContext context) {
    List cover = new List();
    cover.add(artist.photo);
    return ListTile(
      leading: Container(
        height: MediaQuery.of(context).size.height / 13,
        width: MediaQuery.of(context).size.width / 5.8,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: playListCover(cover),
        ),
      ),
      title: Text(artist.title),
      subtitle: Text("Artist"),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => ArtistProfile(artist))),
    );
  }
}
