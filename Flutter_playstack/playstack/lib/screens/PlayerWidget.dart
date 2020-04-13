import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/src/foundation/constants.dart';
import 'package:http/http.dart' as http;

enum PlayerState { stopped, playing, paused }
enum PlayingRouteState { speakers, earpiece }

class PlayerWidget extends StatefulWidget {
  final String url;
  final PlayerMode mode;
  final AudioPlayer advancedPlayer;

  PlayerWidget(
      {Key key,
      @required this.url,
      @required this.advancedPlayer,
      this.mode = PlayerMode.MEDIA_PLAYER})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState(url, mode);
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  String url;
  bool seekDone;

  PlayerMode mode;

  AudioPlayer _audioPlayer;
  AudioPlayerState _audioPlayerState;
  Duration _duration;
  Duration _position;

  PlayerState _playerState = PlayerState.stopped;
  PlayingRouteState _playingRouteState = PlayingRouteState.speakers;
  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  StreamSubscription _playerStateSubscription;

  _PlayerWidgetState(this.url, this.mode);

  get _isPlaying => _playerState == PlayerState.playing;
  get _isPaused => _playerState == PlayerState.paused;
  get _durationText => _duration?.toString()?.split('.')?.first ?? '';
  get _positionText => _position?.toString()?.split('.')?.first ?? '';

  @override
  void initState() {
    widget.advancedPlayer.seekCompleteHandler =
        (finished) => setState(() => seekDone = finished);
    super.initState();
    _initAudioPlayer();
  }

  Future<String> _getSongUrl(String songName) async {
    print("Intento conger url");

    var jsonResponse = null;
    var response = await http
        .get("https://playstack.azurewebsites.net/GetSong?Titulo=$songName");
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

  void _onComplete() {
    setState(() => _playerState = PlayerState.stopped);
  }

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer(mode: mode);

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);

      // Para que aparezca en la barra de notificaciones la reproducción, sólo implementado para iOS
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        // (Optional) listen for notification updates in the background
        _audioPlayer.startHeadlessService();

        // set at least title to see the notification bar on ios.
        _audioPlayer.setNotification(
            title: 'App Name',
            artist: 'Artist or blank',
            albumTitle: 'Name or blank',
            imageUrl: 'url or blank',
            forwardSkipInterval: const Duration(seconds: 30), // default is 30s
            backwardSkipInterval: const Duration(seconds: 30), // default is 30s
            duration: duration,
            elapsedTime: Duration(seconds: 0));
      }
    });

    // Listener para actualizar la posición de la canción
    _positionSubscription =
        _audioPlayer.onAudioPositionChanged.listen((p) => setState(() {
              _position = p;
            }));

    // Listener para cuando acabe
    _playerCompleteSubscription =
        _audioPlayer.onPlayerCompletion.listen((event) {
      _onComplete();
      setState(() {
        _position = _duration;
      });
    });

    _playerErrorSubscription = _audioPlayer.onPlayerError.listen((msg) {
      print('audioPlayer error : $msg');
      setState(() {
        _playerState = PlayerState.stopped;
        _duration = Duration(seconds: 0);
        _position = Duration(seconds: 0);
      });
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _audioPlayerState = state;
      });
    });

    _audioPlayer.onNotificationPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _audioPlayerState = state);
    });

    _playingRouteState = PlayingRouteState.speakers;
  }

  Future<int> _pause() async {
    final result = await _audioPlayer.pause();
    if (result == 1) setState(() => _playerState = PlayerState.paused);
    return result;
  }

  Future<int> _stop() async {
    final result = await _audioPlayer.stop();
    if (result == 1) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration();
      });
    }
    return result;
  }

  Future<int> _play() async {
    final playPosition = (_position != null &&
            _duration != null &&
            _position.inMilliseconds > 0 &&
            _position.inMilliseconds < _duration.inMilliseconds)
        ? _position
        : null;
    final result = await _audioPlayer.play(url, position: playPosition);
    if (result == 1) setState(() => _playerState = PlayerState.playing);

    // default playback rate is 1.0
    // this should be called after _audioPlayer.play() or _audioPlayer.resume()
    // this can also be called everytime the user wants to change playback rate in the UI
    _audioPlayer.setPlaybackRate(playbackRate: 1.0);

    return result;
  }

  Future<int> _release() async {
    final result = await _audioPlayer.setReleaseMode(ReleaseMode.RELEASE);
    print("Release result" + result.toString());

    return result;
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                key: Key('play_button'),
                onPressed: _isPlaying ? null : () => _play(),
                iconSize: 64.0,
                icon: Icon(Icons.play_arrow),
                color: Colors.cyan,
              ),
              IconButton(
                key: Key('pause_button'),
                onPressed: _isPlaying ? () => _pause() : null,
                iconSize: 64.0,
                icon: Icon(Icons.pause),
                color: Colors.cyan,
              ),
              IconButton(
                key: Key('stop_button'),
                onPressed: _isPlaying || _isPaused ? () => _stop() : null,
                iconSize: 64.0,
                icon: Icon(Icons.stop),
                color: Colors.cyan,
              ),
              IconButton(
                onPressed: () => _release(),
                iconSize: 64.0,
                icon: Icon(Icons.volume_up),
                color: Colors.cyan,
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Stack(
                  children: [
                    Slider(
                      onChanged: (v) {
                        final Position = v * _duration.inMilliseconds;
                        _audioPlayer
                            .seek(Duration(milliseconds: Position.round()));
                      },
                      value: (_position != null &&
                              _duration != null &&
                              _position.inMilliseconds > 0 &&
                              _position.inMilliseconds <
                                  _duration.inMilliseconds)
                          ? _position.inMilliseconds / _duration.inMilliseconds
                          : 0.0,
                    ),
                  ],
                ),
              ),
              Text(
                _position != null
                    ? '${_positionText ?? ''} / ${_durationText ?? ''}'
                    : _duration != null ? _durationText : '',
                style: TextStyle(fontSize: 24.0),
              ),
            ],
          ),
          Text('State: $_audioPlayerState')
        ],
      ),
    );
  }
}
