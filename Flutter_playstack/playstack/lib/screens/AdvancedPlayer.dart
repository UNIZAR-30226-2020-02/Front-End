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

import 'PlayingNow.dart';

class Advanced extends StatefulWidget {
  final AudioPlayer advancedPlayer;

  const Advanced({Key key, this.advancedPlayer}) : super(key: key);

  @override
  _AdvancedState createState() => _AdvancedState();
}

class _AdvancedState extends State<Advanced> {
  bool seekDone;

  @override
  void initState() {
    widget.advancedPlayer.seekCompleteHandler =
        (finished) => setState(() => seekDone = finished);
    super.initState();
  }

  Future<String> _getSongUrl() async {
    print("Intento conger url");

    var jsonResponse = null;
    var response = await http
        .get("https://playstack.azurewebsites.net/GetSong?Titulo=Audio");
    /*var response = await http.get(
      Uri.encodeFull("https://jsonplaceholder.typicode.com/posts"),
    );*/
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      if (jsonResponse != null) {
        print("Json response: " + jsonResponse.toString());
        print("Url: " + jsonResponse[0]["URL"].toString());
        return jsonResponse[0]["URL"];
      }
    } else {
      print("Status code not 200, body: " + response.body);
      return null;
    }
    print("Statuscode: " + response.statusCode.toString());
  }

  @override
  Widget build(BuildContext context) {
    final audioPosition = Provider.of<Duration>(context);
    return SingleChildScrollView(
      child: _Tab(
        children: [
          Column(children: [
            Text('Source Url'),
            Row(children: [
              _Btn(
                  txt: 'Audio 1',
                  onPressed: () => widget.advancedPlayer
                      .setUrl(kUrl1)), //widget.advancedPlayer.setUrl(kUrl1)),
            ], mainAxisAlignment: MainAxisAlignment.spaceEvenly),
          ]),
          Column(children: [
            Text('Release Mode'),
            Row(children: [
              _Btn(
                  txt: 'STOP',
                  onPressed: () =>
                      widget.advancedPlayer.setReleaseMode(ReleaseMode.STOP)),
              _Btn(
                  txt: 'LOOP',
                  onPressed: () =>
                      widget.advancedPlayer.setReleaseMode(ReleaseMode.LOOP)),
              _Btn(
                  txt: 'RELEASE',
                  onPressed: () => widget.advancedPlayer
                      .setReleaseMode(ReleaseMode.RELEASE)),
            ], mainAxisAlignment: MainAxisAlignment.spaceEvenly),
          ]),
          Column(children: [
            Text('Volume'),
            Row(children: [
              _Btn(
                  txt: '0.0',
                  onPressed: () => widget.advancedPlayer.setVolume(0.0)),
              _Btn(
                  txt: '0.5',
                  onPressed: () => widget.advancedPlayer.setVolume(0.5)),
              _Btn(
                  txt: '1.0',
                  onPressed: () => widget.advancedPlayer.setVolume(1.0)),
              _Btn(
                  txt: '2.0',
                  onPressed: () => widget.advancedPlayer.setVolume(2.0)),
            ], mainAxisAlignment: MainAxisAlignment.spaceEvenly),
          ]),
          Column(children: [
            Text('Control'),
            Row(children: [
              _Btn(
                  txt: 'resume',
                  onPressed: () => widget.advancedPlayer.resume()),
              _Btn(
                  txt: 'pause', onPressed: () => widget.advancedPlayer.pause()),
              _Btn(txt: 'stop', onPressed: () => widget.advancedPlayer.stop()),
              _Btn(
                  txt: 'release',
                  onPressed: () => widget.advancedPlayer.release()),
            ], mainAxisAlignment: MainAxisAlignment.spaceEvenly),
          ]),
          Column(children: [
            Text('Seek in milliseconds'),
            Row(children: [
              _Btn(
                  txt: '100ms',
                  onPressed: () {
                    widget.advancedPlayer.seek(Duration(
                        milliseconds: audioPosition.inMilliseconds + 100));
                    setState(() => seekDone = false);
                  }),
              _Btn(
                  txt: '500ms',
                  onPressed: () {
                    widget.advancedPlayer.seek(Duration(
                        milliseconds: audioPosition.inMilliseconds + 500));
                    setState(() => seekDone = false);
                  }),
              _Btn(
                  txt: '1s',
                  onPressed: () {
                    widget.advancedPlayer
                        .seek(Duration(seconds: audioPosition.inSeconds + 1));
                    setState(() => seekDone = false);
                  }),
              _Btn(
                  txt: '1.5s',
                  onPressed: () {
                    widget.advancedPlayer.seek(Duration(
                        milliseconds: audioPosition.inMilliseconds + 1500));
                    setState(() => seekDone = false);
                  }),
            ], mainAxisAlignment: MainAxisAlignment.spaceEvenly),
          ]),
          Column(children: [
            Text('Rate'),
            Row(children: [
              _Btn(
                  txt: '0.5',
                  onPressed: () =>
                      widget.advancedPlayer.setPlaybackRate(playbackRate: 0.5)),
              _Btn(
                  txt: '1.0',
                  onPressed: () =>
                      widget.advancedPlayer.setPlaybackRate(playbackRate: 1.0)),
              _Btn(
                  txt: '1.5',
                  onPressed: () =>
                      widget.advancedPlayer.setPlaybackRate(playbackRate: 1.5)),
              _Btn(
                  txt: '2.0',
                  onPressed: () =>
                      widget.advancedPlayer.setPlaybackRate(playbackRate: 2.0)),
            ], mainAxisAlignment: MainAxisAlignment.spaceEvenly),
          ]),
          Text('Audio Position: ${audioPosition}'),
          seekDone == null
              ? SizedBox(
                  width: 0,
                  height: 0,
                )
              : Text(seekDone ? "Seek Done" : "Seeking..."),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final String txt;
  final VoidCallback onPressed;

  const _Btn({Key key, this.txt, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
        minWidth: 48.0,
        child: RaisedButton(child: Text(txt), onPressed: onPressed));
  }
}

class _Tab extends StatelessWidget {
  final List<Widget> children;

  const _Tab({Key key, this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: children
                .map((w) => Container(child: w, padding: EdgeInsets.all(6.0)))
                .toList(),
          ),
        ),
      ),
    );
  }
}
