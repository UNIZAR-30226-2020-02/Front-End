import 'package:flutter/material.dart';
import 'package:playstack/shared/common.dart';

class LocalSong {
  LocalSong({this.name, this.path});

  String name;
  String path;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'path': path,
    };
  }
}
