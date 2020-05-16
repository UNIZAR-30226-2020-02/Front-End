import 'package:flutter/material.dart';
import 'package:playstack/screens/Homescreen/ArtistProfile.dart';

class Artist {
  String name;
  String photo;
  Artist(this.name, this.photo);
}

class ArtistTile extends StatelessWidget {
  final Artist artist;
  ArtistTile(this.artist);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(artist.name),
        leading: CircleAvatar(
            radius: 30, backgroundImage: NetworkImage(artist.photo)),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => ArtistProfile(artist))),
      ),
    );
  }
}
