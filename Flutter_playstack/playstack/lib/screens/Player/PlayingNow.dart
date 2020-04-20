import 'dart:io';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:playstack/models/Song.dart';
import 'package:playstack/screens/Player/PlayerWidget.dart';
import 'package:playstack/shared/common.dart';
import 'package:provider/provider.dart';

class PlayingNowScreen extends StatefulWidget {
  PlayingNowScreen();
  @override
  _PlayingNowScreenState createState() => _PlayingNowScreenState();
}

class _PlayingNowScreenState extends State<PlayingNowScreen> {
  // Para canciones de assets
  AudioCache audioCache = AudioCache();
  //Para canciones online SOLO HTTPS no HTTP
  AudioPlayer advancedPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    if (Platform.isIOS) {
      if (audioCache.fixedPlayer != null) {
        audioCache.fixedPlayer.startHeadlessService();
      }
      advancedPlayer.startHeadlessService();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      StreamProvider<Duration>.value(
          initialData: Duration(),
          value: advancedPlayer.onAudioPositionChanged),
    ], child: PlayerWidget(advancedPlayer: advancedPlayer));
  }
}