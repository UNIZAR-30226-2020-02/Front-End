import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playstack/screens/Library/Playlist.dart';
import 'package:playstack/screens/mainscreen.dart';
import 'package:playstack/services/SQLite.dart';

class LocalPlaylist {
  String name;

  LocalPlaylist({this.name});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}
