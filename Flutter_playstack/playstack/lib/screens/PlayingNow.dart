import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:playstack/screens/AdvancedPlayer.dart';
import 'package:playstack/screens/PlayerWidget.dart';
import 'package:provider/provider.dart';
import 'package:flutter/src/foundation/constants.dart';
import 'package:http/http.dart' as http;

const kUrl1 = 'https://luan.xyz/files/audio/ambient_c_motion.mp3';

class PlayingNowScreen extends StatefulWidget {
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
    ], child: PlayerWidget(url: kUrl1, advancedPlayer: advancedPlayer));
  }
}
