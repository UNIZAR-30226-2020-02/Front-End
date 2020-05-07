import 'dart:io';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:playstack/models/Song.dart';
import 'package:playstack/screens/Player/PlayingNow.dart';
import 'package:playstack/screens/Player/UpNext.dart';
import 'package:playstack/shared/common.dart';
import 'package:marquee/marquee.dart';

enum PlayerState { stopped, playing, paused }
enum PlayingRouteState { speakers, earpiece }

class PlayerWidget extends StatefulWidget {
  final PlayerMode mode;
  final AudioPlayer advancedPlayer;

  PlayerWidget(
      {Key key,
      @required this.advancedPlayer,
      this.mode = PlayerMode.MEDIA_PLAYER})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState(mode);
  }
}

class _PlayerWidgetState extends State<PlayerWidget>
    with SingleTickerProviderStateMixin {
  bool _showCover;
  bool seekDone;
  bool _loopEnabled;
  bool _shuffleEnabled;

  PageController _pageController = new PageController(initialPage: 0);
  PageController _backController = new PageController(initialPage: 0);

  double width;

  PlayerMode mode;

  AudioPlayer _audioPlayer;
  AudioPlayerState _audioPlayerState;
  Duration _duration;
  Duration _position;

  List<Song> allSongs = [];
  int currentPage = 0;
  bool _usingButtons = false;
  int absoluteChangeInPage = 0;
  bool _pressing = false;

  PlayerState _playerState = PlayerState.stopped;
  PlayingRouteState _playingRouteState = PlayingRouteState.speakers;
  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  StreamSubscription _playerStateSubscription;

  _PlayerWidgetState(this.mode);

  AnimationController _animationController;
  Animation<Color> _animateColor;
  Animation<double> _animateIcon;

  get _isPlaying => _playerState == PlayerState.playing;
  get _isPaused => _playerState == PlayerState.paused;
  get _durationText => _duration?.toString()?.split('.')?.first ?? '';
  get _positionText => _position?.toString()?.split('.')?.first ?? '';

  @override
  void initState() {
    print("Url de la cancion: " + currentSong.url);
    widget.advancedPlayer.seekCompleteHandler =
        (finished) => setState(() => seekDone = finished);
    super.initState();
    _showCover = false;
    _loopEnabled = false;
    _shuffleEnabled = true;

    _pageController.addListener(() {
      _backController.jumpTo(_pageController.offset);
      print(absoluteChangeInPage);
      if ((_pageController.page - currentPage).abs() > 0.9) {
        if (absoluteChangeInPage > 0) {
          skipSong(false);
        } else if (absoluteChangeInPage < 0) {
          skipPrevious(false);
        }
        absoluteChangeInPage = 0;
      }
    });

    initAnim();
    _initAudioPlayer();
    if (_playerState != PlayerState.playing) {
      togglePlayPause();
    }
  }

  void _onComplete() {
    setState(() => _playerState = PlayerState.stopped);
  }

  void buildPageLists(bool onlyNext) {
    if (!onlyNext) {
      songsPlayed.forEach((value) {
        allSongs.add(value);
      });

      allSongs.add(currentSong);
    }

    songsNextUp.forEach((value) {
      allSongs.add(value);
    });
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
    final result =
        await _audioPlayer.play(currentSong.url, position: playPosition);
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

  void skipPrevious(bool mustScroll) {
    if (songsPlayed.isNotEmpty) {
      if (_isPlaying) {
        togglePlayPause();
      }

      setState(() {
        songsNextUp.insert(0, currentSong);
        currentSong = songsPlayed.last;
        songsPlayed.removeAt(songsPlayed.length - 1);
      });
      if (mustScroll) {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        _backController.previousPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        Future.delayed(
            Duration(milliseconds: 400), () => _usingButtons = false);
      }
      currentPage -= 1;
      currentSong.markAsListened();
      _position = Duration(seconds: 0);
      _duration = Duration(seconds: 0);
      Future.delayed(Duration(milliseconds: mustScroll ? 900 : 500), () {
        if (!_isPlaying) togglePlayPause();
      });

      //Navigator.of(context).pushReplacement(MaterialPageRoute(
      //    builder: (BuildContext context) => PlayingNowScreen()));

    }
  }

  void skipSong(bool mustScroll) {
    print("Skipping...");

    if (songsNextUp.isNotEmpty || _loopEnabled) {
      if (_isPlaying) {
        togglePlayPause();
      }
      if (songsNextUp.isNotEmpty) {
        setState(() {
          songsPlayed.add(currentSong);
          currentSong = songsNextUp.first;
          songsNextUp.removeAt(0);
        });
      } else {
        songsNextUp = allSongs;
        if (_shuffleEnabled) {
          setShuffleQueue(songsNextUpName, songsNextUp,
              songsNextUp.elementAt(rng.nextInt(songsPlayed.length)));
        }
        buildPageLists(true);
      }
      if (mustScroll) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        _backController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        Future.delayed(
            Duration(milliseconds: 400), () => _usingButtons = false);
      }
      currentPage += 1;
      currentSong.markAsListened();
      _position = Duration(seconds: 0);
      _duration = Duration(seconds: 0);
      Future.delayed(Duration(milliseconds: mustScroll ? 900 : 500), () {
        if (!_isPlaying) togglePlayPause();
      });

      //Navigator.of(context).pushReplacement(MaterialPageRoute(
      //    builder: (BuildContext context) => PlayingNowScreen()));

    }
  }

  dynamic getImage(Song song) {
    if (song.albumCoverUrls == null) return null;
    return song == null
        ? null
        : new File.fromUri(Uri.parse(song.albumCoverUrls.elementAt(0)));
  }

  initAnim() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animateColor = ColorTween(
      begin: Colors.white.withOpacity(0.7),
      end: Colors.white.withOpacity(0.7),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
  }

  void togglePlayPause() {
    if (_isPlaying) {
      _animationController.forward();
      _pause();
    } else {
      _animationController.reverse();
      _play();
    }
  }

  Widget slidingText({String texto, bool condicion, TextStyle estilo}) {
    return condicion
        ? Marquee(
            text: texto,
            style: estilo,
            scrollAxis: Axis.horizontal,
            blankSpace: width / 2,
            velocity: 100.0,
            pauseAfterRound: Duration(seconds: 5),
            startPadding: 10.0,
            accelerationDuration: Duration(seconds: 1),
            accelerationCurve: Curves.linear,
            decelerationDuration: Duration(seconds: 1),
            decelerationCurve: Curves.easeOut,
          )
        : Text(
            texto,
            style: estilo,
            maxLines: 1,
            textAlign: TextAlign.center,
          );
  }

  Widget infoCancion(Song song) {
    return Column(children: <Widget>[
      Padding(
        //Carátula
        padding: EdgeInsets.only(top: width / 50),
        child: Container(
          height: width * 0.8,
          width: width * 0.8,
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8.0),
              image: DecorationImage(
                  image: song.albumCoverUrls.elementAt(0) != null
                      ? NetworkImage(song.albumCoverUrls.elementAt(0))
                      : Image.asset("assets/images/defaultCover.png").image,
                  fit: BoxFit.cover)),
        ),
      ),
      Padding(
          //Título
          padding: EdgeInsets.only(top: width / 50),
          child: Container(
              height: width / 10,
              child: Material(
                  color: Colors.transparent,
                  child: Center(
                      child: slidingText(
                          texto: '${song.title}',
                          condicion: song.title.length * 18.40 > width,
                          estilo: new TextStyle(
                              color: Colors.white,
                              fontSize: width / 18.40,
                              fontWeight: FontWeight.w600)))))),
      Padding(
          //Artistas
          padding: EdgeInsets.only(top: width * 0.0005),
          child: Container(
              height: width / 20,
              child: Material(
                  color: Colors.transparent,
                  child: slidingText(
                      texto: getSongArtists(song.artists),
                      condicion: song.artists.length * 24.50 > width,
                      estilo: new TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: width / 24.50,
                          letterSpacing: width / 245,
                          height: width / 294))))),
    ]);
  }

  Widget fondo(Song song) {
    return Container(
        //Fondo
        height: MediaQuery.of(context).size.height,
        child: song.albumCoverUrls == null
            ? Image.asset(
                'assets/images/defaultCover.png',
                fit: BoxFit.fitWidth,
                width: MediaQuery.of(context).size.width,
              )
            : Image.network(song.albumCoverUrls.elementAt(0),
                fit: BoxFit.fitHeight));
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    allSongs.clear();
    buildPageLists(false);
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double ccPadding = MediaQuery.of(context).size.width / 12;
    return Stack(children: <Widget>[
      Container(
        height: MediaQuery.of(context).size.height,
        child: PageView.builder(
            itemCount: allSongs.length,
            controller: _backController,
            pageSnapping: false,
            physics: new NeverScrollableScrollPhysics(),
            itemBuilder: (context, int index) => fondo(allSongs[index])),
      ),
      BackdropFilter(
        //Difuminado
        filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: new BoxDecoration(color: Colors.black54.withOpacity(0.5)),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(top: width / 20),
        child: Column(
          children: <Widget>[
            //Equis para cerrar
            Padding(
                padding: EdgeInsets.only(left: width / 30),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                        color: Colors.transparent,
                        child: IconButton(
                            icon: Icon(
                              CupertinoIcons.clear,
                              size: 35,
                            ),
                            onPressed: () => Navigator.of(context).pop())))),
            Align(
                alignment: Alignment.topCenter,
                child: Column(children: <Widget>[
                  Container(
                      height: width * 0.9905,
                      child: PageView.builder(
                          itemCount: allSongs.length,
                          onPageChanged: (newpage) {
                            if (!_usingButtons) {
                              if (newpage - currentPage > 0) {
                                absoluteChangeInPage += 1;
                              } else {
                                absoluteChangeInPage -= 1;
                              }
                            }
                          },
                          controller: _pageController,
                          //physics: new NeverScrollableScrollPhysics(),
                          itemBuilder: (context, int index) =>
                              infoCancion(allSongs[index]))),
                  Padding(
                      //Slider
                      padding: EdgeInsets.only(
                          top: width * 0.05,
                          left: width * 0.05,
                          right: width * 0.05),
                      child: Container(
                          height: width / 20,
                          child: Material(
                            color: Colors.transparent,
                            child: Slider(
                              activeColor: Colors.white.withOpacity(0.8),
                              inactiveColor: Colors.grey.withOpacity(0.5),
                              onChanged: (v) {
                                final position = v * _duration.inMilliseconds;
                                _audioPlayer.seek(
                                    Duration(milliseconds: position.round()));
                              },
                              value: (_position != null &&
                                      _duration != null &&
                                      _position.inMilliseconds > 0 &&
                                      _position.inMilliseconds <
                                          _duration.inMilliseconds)
                                  ? _position.inMilliseconds /
                                      _duration.inMilliseconds
                                  : 0.0,
                            ),
                          ))),
                  Padding(
                      //Posicion actual
                      padding: EdgeInsets.only(top: width * 0.005),
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          _positionText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.white.withOpacity(0.6),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0),
                        ),
                      )),
                  Padding(
                      //SECCION DE BOTONES
                      padding: EdgeInsets.fromLTRB(
                          width * 0.05, width * 0.05, width * 0.05, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                              //Bucle
                              flex: 10,
                              child: Container(
                                  height: width / 10,
                                  child: Center(
                                      child: Material(
                                          color: Colors.transparent,
                                          child: GestureDetector(
                                            child: Icon(
                                              Icons.loop,
                                              color: _loopEnabled
                                                  ? Colors.red
                                                  : Colors.white
                                                      .withOpacity(0.8),
                                              size: width / 17.62,
                                            ),
                                            onTap: () => setState(() =>
                                                _loopEnabled = !_loopEnabled),
                                          ))))),
                          Expanded(
                              //Atrás
                              flex: 15,
                              child: Container(
                                  height: width / 5,
                                  child: Center(
                                      child: Material(
                                          color: Colors.transparent,
                                          child: GestureDetector(
                                            child: Icon(
                                              Icons.skip_previous,
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              size: width / 8.82,
                                            ),
                                            onTap: () {
                                              _usingButtons = true;
                                              skipPrevious(true);
                                            },
                                          ))))),
                          Expanded(
                              //Botones apilados (Play/Pause y Cola)
                              flex: 20,
                              child: Container(
                                  height: width / 5,
                                  child: Center(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                        Expanded(
                                            //Play/Pause
                                            flex: 3,
                                            child: Material(
                                                color: Colors.transparent,
                                                child: FloatingActionButton(
                                                  backgroundColor: Colors.white
                                                      .withOpacity(0.6),
                                                  child: AnimatedIcon(
                                                      color: Colors.white,
                                                      size: width / 9.8,
                                                      icon: AnimatedIcons
                                                          .pause_play,
                                                      progress: _animateIcon),
                                                  onPressed: () =>
                                                      togglePlayPause(),
                                                ))),
                                        Expanded(
                                          //Cola
                                          flex: 1,
                                          child: Material(
                                              color: Colors.transparent,
                                              child: FlatButton(
                                                onPressed: () => Navigator.of(
                                                        context)
                                                    .push(MaterialPageRoute(
                                                        builder: (BuildContext
                                                                context) =>
                                                            UpNext())),
                                                highlightColor: Colors
                                                    .blueGrey[200]
                                                    .withOpacity(0.1),
                                                child: Text(
                                                  languageStrings['upNext'],
                                                  style: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(0.8),
                                                      fontSize: width / 50,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                splashColor: Colors
                                                    .blueGrey[200]
                                                    .withOpacity(0.1),
                                              )),
                                        )
                                      ])))),
                          Expanded(
                              //Siguiente
                              flex: 15,
                              child: Container(
                                  height: width / 5,
                                  child: Center(
                                      child: Material(
                                          color: Colors.transparent,
                                          child: GestureDetector(
                                              child: Icon(
                                                Icons.skip_next,
                                                color: Colors.white
                                                    .withOpacity(0.8),
                                                size: width / 8.82,
                                              ),
                                              onTap: () {
                                                _usingButtons = true;
                                                skipSong(true);
                                              }))))),
                          Expanded(
                              //Favorita
                              flex: 10,
                              child: Container(
                                  height: width / 10,
                                  child: Center(
                                      child: Material(
                                          color: Colors.transparent,
                                          child: GestureDetector(
                                              child: Icon(
                                                currentSong.isFav
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: currentSong.isFav
                                                    ? Colors.red
                                                    : Colors.white
                                                        .withOpacity(0.8),
                                                size: width / 17.62,
                                              ),
                                              onTap: () async {
                                                if (currentSong.isFav) {
                                                  await currentSong
                                                      .removeFromFavs();
                                                  setState(() {});
                                                } else {
                                                  await currentSong.setAsFav();
                                                  setState(() {});
                                                }
                                              })))))
                        ],
                      ))
                ]))
          ],
        ),
      )
    ]);

    /*
              child: Padding(
                padding: EdgeInsets.only(top: width * 0.06 * 10),
                child: Container(
                  width: width * 0.8,
                  height: width * 0.8,
                  child: new AspectRatio(
                      aspectRatio: 15 / 15,
                      child: Hero(
                        tag: song.title,
                        child: song.albumCoverUrls.elementAt(0) != null
                            ? Material(
                                color: Colors.transparent,
                                elevation: 22,
                                child: InkWell(
                                  onDoubleTap: () {
                                    setState(() {
                                      _showCover = !_showCover;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(cutRadius),
                                        image: DecorationImage(
                                            image: NetworkImage(song
                                                .albumCoverUrls
                                                .elementAt(0)),
                                            fit: BoxFit.cover)),
                                    child: Stack(
                                      children: <Widget>[
                                        _showCover
                                            ? Container(
                                                width: width - 2 * width * 0.06,
                                                height: width - width * 0.06,
                                                child:
                                                    Text("GetArtist details"))
                                            : Container(),
                                        Positioned(
                                          bottom: 0.0,
                                          right: 0.0,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                right: 4.0, bottom: 6.0),
                                            child: Text(
                                              _durationText,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Material(
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(cutRadius)),
                                clipBehavior: Clip.antiAlias,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: <Widget>[
                                    Image.asset(
                                      "assets/images/defaultCover.png",
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      bottom: -width * 0.15,
                                      right: -width * 0.15,
                                      child: Container(
                                        decoration: ShapeDecoration(
                                            color: Colors.white,
                                            shape: BeveledRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(
                                                        width * 0.15)))),
                                        height: width * 0.15 * 2,
                                        width: width * 0.15 * 2,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0.0,
                                      right: 0.0,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            right: 4.0, bottom: 6.0),
                                        child: Text(
                                          _durationText,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      )),
                ),
              )),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: width * 1.11),
            child: Container(
              color: Colors.transparent,
              height: MediaQuery.of(context).size.height - width * 1.11,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).size.height / 50),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          color: Colors.transparent,
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, right: 10.0, top: 5),
                                child: new Text(
                                  '${song.title}\n',
                                  style: new TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      letterSpacing: 1.5,
                                      fontWeight: FontWeight.w500,
                                      height: 1.5),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Text(
                                getSongArtists(song.artists),
                                style: new TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 18.0,
                                    letterSpacing: 1.8,
                                    height: 1.5),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Material(
                          color: Colors.transparent,
                          child: Container(
                            color: Colors.transparent,
                            width: width * 0.85,
                            padding: EdgeInsets.only(
                              left: statusBarHeight * 0.5,
                            ),
                            child: Slider(
                              activeColor: Colors.white.withOpacity(0.8),
                              inactiveColor: Colors.grey.withOpacity(0.5),
                              onChanged: (v) {
                                final Position = v * _duration.inMilliseconds;
                                _audioPlayer.seek(
                                    Duration(milliseconds: Position.round()));
                              },
                              value: (_position != null &&
                                      _duration != null &&
                                      _position.inMilliseconds > 0 &&
                                      _position.inMilliseconds <
                                          _duration.inMilliseconds)
                                  ? _position.inMilliseconds /
                                      _duration.inMilliseconds
                                  : 0.0,
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: Text(
                            _positionText,
                            style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.white.withOpacity(0.6),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        color: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: new Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(width: ccPadding),
                              Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 15.0)),
                              new IconButton(
                                splashColor: Colors.blueGrey[200],
                                highlightColor: Colors.transparent,
                                icon: new Icon(
                                  Icons.skip_previous,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 50.0,
                                ),
                                //TODO: boton de anterior cancion
                                onPressed: () => skipPrevious(),
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.only(left: 35.0, right: 20.0),
                                child: Container(
                                  height: 80,
                                  width: 80,
                                  child: FloatingActionButton(
                                    backgroundColor: _animateColor.value,
                                    child: new AnimatedIcon(
                                        color: Colors.white,
                                        size: 45,
                                        icon: AnimatedIcons.pause_play,
                                        progress: _animateIcon),
                                    onPressed: () => togglePlayPause(),
                                  ),
                                ),
                              ),
                              new IconButton(
                                splashColor:
                                    Colors.blueGrey[200].withOpacity(0.5),
                                highlightColor: Colors.transparent,
                                icon: new Icon(
                                  Icons.skip_next,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 50.0,
                                ),
                                onPressed: () => skipSong(),
                              ),
                              Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 15.0)),
                              new IconButton(
                                  icon: song.isFav
                                      ? new Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                          size: 35.0,
                                        )
                                      : new Icon(
                                          Icons.favorite_border,
                                          color: Colors.red,
                                          size: 35.0,
                                        ),
                                  onPressed: () async {
                                    if (song.isFav) {
                                      await song.removeFromFavs();
                                      setState(() {});
                                    } else {
                                      await song.setAsFav();
                                      setState(() {});
                                    }
                                  })
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Container(
                      width: width,
                      color: Colors.transparent,
                      child: FlatButton(
                        onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (BuildContext context) => UpNext())),
                        highlightColor: Colors.blueGrey[200].withOpacity(0.1),
                        child: Text(
                          "UP NEXT",
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.bold),
                        ),
                        splashColor: Colors.blueGrey[200].withOpacity(0.1),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget oldPlayer() {
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
    );*/
  }
}
