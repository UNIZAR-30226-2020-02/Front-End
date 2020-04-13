import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/src/foundation/constants.dart';
import 'package:http/http.dart' as http;

import 'PlayerWidget.dart';

class PlayerScreen extends StatefulWidget {
  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  AudioPlayer audioPlayer = AudioPlayer();
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<Duration>.value(
            initialData: Duration(), value: audioPlayer.onAudioPositionChanged),
      ],
      child: Center(child: RaisedButton(onPressed: () async {
        var res = await audioPlayer
            .play('http://playstack.azurewebsites.net/media/audio/Audio5.mp3');
        print("Resultcode: " + res.toString());
      })),
    );
  }
}
