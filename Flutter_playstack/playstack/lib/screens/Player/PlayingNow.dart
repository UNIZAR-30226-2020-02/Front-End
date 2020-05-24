import 'dart:io';
import 'package:flutter/material.dart';
import 'package:playstack/screens/Player/PlayerWidget.dart';
import 'package:playstack/shared/common.dart';

class PlayingNowScreen extends StatefulWidget {
  @override
  _PlayingNowScreenState createState() => _PlayingNowScreenState();
}

class _PlayingNowScreenState extends State<PlayingNowScreen> {
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
    onPlayerScreen = true;
    return PlayerWidget();
  }
}
