import 'dart:io';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:playstack/screens/mainscreen.dart';
import 'package:flutter/foundation.dart';
import 'package:playstack/models/Song.dart';
import 'package:playstack/shared/common.dart';
import 'package:playstack/screens/Player/UpNext.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';

class PlayerWidget extends StatefulWidget {
  PlayerWidget._constructor();

  static final PlayerWidget _instance = PlayerWidget._constructor();

  factory PlayerWidget() {
    return _instance;
  }

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState(mode);
  }
}

class _PlayerWidgetState extends State<PlayerWidget>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  bool _pressing = false;
  bool _showCover;
  bool seekDone;
  bool _loopEnabled;
  bool _shuffleEnabled;
  bool _usingButtons = false;
  int absoluteChangeInPage = 0;

  PageController _pageController = new PageController(initialPage: 0);
  PageController _backController = new PageController(initialPage: 0);

  double width;
  int currentPage = 0;

  _PlayerWidgetState(mode);

  AnimationController _animationController;
  Animation<Color> _animateColor;
  Animation<double> _animateIcon;

  @override
  bool get wantKeepAlive => true;

  void _initAudioPlayer() {
    if (!playerActive) {
      advancedPlayer.mode = mode;

      durationSubscription =
          advancedPlayer.onDurationChanged.listen((duration) {
        setState(() => duration = duration);

        // Para que aparezca en la barra de notificaciones la reproducción, sólo implementado para iOS
        if (Theme.of(context).platform == TargetPlatform.iOS) {
          // (Optional) listen for notification updates in the background
          advancedPlayer.startHeadlessService();

          // set at least title to see the notification bar on ios.
          advancedPlayer.setNotification(
              title: 'App Name',
              artist: 'Artist or blank',
              albumTitle: 'Name or blank',
              imageUrl: 'url or blank',
              forwardSkipInterval:
                  const Duration(seconds: 30), // default is 30s
              backwardSkipInterval:
                  const Duration(seconds: 30), // default is 30s
              duration: duration,
              elapsedTime: Duration(seconds: 0));
        }
      });

      // Listener para actualizar la posición de la canción
      positionSubscription =
          advancedPlayer.onAudioPositionChanged.listen((p) => setState(() {
                position = p;
              }));

      // Listener para cuando acabe
      playerCompleteSubscription =
          advancedPlayer.onPlayerCompletion.listen((event) {
        if (position >= duration) {
          //_onComplete();
          //setState(() {
          //  position = duration;
          //});
          skipSong(true);
        }
      });

      playerErrorSubscription = advancedPlayer.onPlayerError.listen((msg) {
        print('advancedPlayer error : $msg');
        setState(() {
          playerState = PlayerState.stopped;
          position = Duration(seconds: 0);
        });
      });

      advancedPlayer.onPlayerStateChanged.listen((state) {
        if (!mounted) return;
        setState(() {
          audioPlayerState = state;
        });
      });

      advancedPlayer.onNotificationPlayerStateChanged.listen((state) {
        if (!mounted) return;
        setState(() => audioPlayerState = state);
      });

      playingRouteState = PlayingRouteState.SPEAKERS;
    }
  }

  @override
  void initState() {
    print("Url de la cancion: " + currentSong.url);
    advancedPlayer.seekCompleteHandler =
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
    if (playerState != PlayerState.playing && !playerActive) {
      togglePlayPause();
    }
    playerActive = true;
  }

  void _onComplete() {
    setState(() => playerState = PlayerState.stopped);
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

  Future<int> _pause() async {
    final result = await advancedPlayer.pause();
    if (result == 1) setState(() => playerState = PlayerState.paused);
    return result;
  }

  Future<int> _stop() async {
    final result = await advancedPlayer.stop();
    if (result == 1) {
      setState(() {
        playerState = PlayerState.stopped;
        position = Duration();
      });
    }
    return result;
  }

  Future<int> _play() async {
    final playPosition = (position != null &&
            duration != null &&
            position.inMilliseconds > 0 &&
            position.inMilliseconds < duration.inMilliseconds)
        ? position
        : Duration.zero;
    final result =
        await advancedPlayer.play(currentSong.url, position: playPosition);
    if (result == 1) setState(() => playerState = PlayerState.playing);

    // default playback rate is 1.0
    // this should be called after advancedPlayer.play() or advancedPlayer.resume()
    // this can also be called everytime the user wants to change playback rate in the UI
    advancedPlayer.setPlaybackRate(playbackRate: 1.0);

    return result;
  }

  Future<int> _release() async {
    final result = await advancedPlayer.setReleaseMode(ReleaseMode.RELEASE);
    print("Release result" + result.toString());

    return result;
  }

  @override
  void dispose() {
    /*advancedPlayer.stop();
    durationSubscription?.cancel();
    positionSubscription?.cancel();
    playerCompleteSubscription?.cancel();
    playerErrorSubscription?.cancel();
    playerStateSubscription?.cancel();
    super.dispose();*/
  }

  void skipPrevious(bool mustScroll) {
    if (songsPlayed.isNotEmpty) {
      if (isPlaying) {
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
      position = Duration(seconds: 0);
      Future.delayed(Duration(milliseconds: mustScroll ? 900 : 500), () {
        if (!isPlaying) togglePlayPause();
      });

      //Navigator.of(context).pushReplacement(MaterialPageRoute(
      //    builder: (BuildContext context) => PlayingNowScreen()));

    }
  }

  void skipSong(bool mustScroll) {
    print("Skipping...");

    if (songsNextUp.isNotEmpty || _loopEnabled) {
      if (isPlaying) {
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
      position = Duration(seconds: 0);
      Future.delayed(Duration(milliseconds: mustScroll ? 900 : 500), () {
        if (!isPlaying) togglePlayPause();
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
    if (isPlaying) {
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
            velocity: 75.0,
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

  Widget songImage(Song song, double width) {
    return Container(
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
    );
  }

  Widget infoCancion(Song song) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            //Carátula
            padding: EdgeInsets.only(top: width / 50),
            child: songImage(song, width),
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

  Widget backButton(double width) {
    return Container(
        height: width / 5,
        child: Center(
            child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  child: Icon(
                    Icons.skip_previous,
                    color: Colors.white.withOpacity(0.8),
                    size: width / 8.82,
                  ),
                  onTap: () {
                    _usingButtons = true;
                    skipPrevious(true);
                  },
                ))));
  }

  Widget playPauseButton(double width) {
    return Material(
        color: Colors.transparent,
        child: FloatingActionButton(
          backgroundColor: Colors.white.withOpacity(0.6),
          child: AnimatedIcon(
              color: Colors.white,
              size: width / 9.8,
              icon: AnimatedIcons.pause_play,
              progress: _animateIcon),
          onPressed: () => togglePlayPause(),
        ));
  }

  Widget skipNextButton(double width) {
    return Container(
        height: width / 5,
        child: Center(
            child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                    child: Icon(
                      Icons.skip_next,
                      color: Colors.white.withOpacity(0.8),
                      size: width / 8.82,
                    ),
                    onTap: () {
                      _usingButtons = true;
                      skipSong(true);
                    }))));
  }

  Widget upNextButton(double width) {
    return Material(
        color: Colors.transparent,
        child: FlatButton(
          onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (BuildContext context) => UpNext())),
          highlightColor: Colors.blueGrey[200].withOpacity(0.1),
          child: Text(
            languageStrings['upNext'],
            style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: width / 50,
                fontWeight: FontWeight.bold),
          ),
          splashColor: Colors.blueGrey[200].withOpacity(0.1),
        ));
  }

  Widget loopButton(double width) {
    return Container(
        height: width / 10,
        child: Center(
            child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  child: Icon(
                    Icons.loop,
                    color: _loopEnabled
                        ? Colors.red
                        : Colors.white.withOpacity(0.8),
                    size: width / 17.62,
                  ),
                  onTap: () => setState(() => _loopEnabled = !_loopEnabled),
                ))));
  }

  Widget favButton(double width) {
    return Container(
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
                          : Colors.white.withOpacity(0.8),
                      size: width / 17.62,
                    ),
                    onTap: () async {
                      if (currentSong.isFav) {
                        await currentSong.removeFromFavs();
                        setState(() {});
                      } else {
                        await currentSong.setAsFav();
                        setState(() {});
                      }
                    }))));
  }

  Widget controls(double width) {
    return Container(
        height: width * 0.5,
        child: Column(children: <Widget>[
          Padding(
              //Slider
              padding: EdgeInsets.only(
                  top: width * 0.05, left: width * 0.05, right: width * 0.05),
              child: Container(
                  height: width / 20,
                  child: Material(
                    color: Colors.transparent,
                    child: Slider(
                      activeColor: Colors.white.withOpacity(0.8),
                      inactiveColor: Colors.grey.withOpacity(0.5),
                      onChanged: (v) async {
                        final position = v * duration.inMilliseconds;
                        var temp = await advancedPlayer.getDuration();
                        if (temp > position) {
                          print(temp.toString());
                          advancedPlayer
                              .seek(Duration(milliseconds: position.round()));
                        }
                      },
                      value: (position != null &&
                              duration != null &&
                              position.inMilliseconds > 0 &&
                              position.inMilliseconds < duration.inMilliseconds)
                          ? position.inMilliseconds / duration.inMilliseconds
                          : 0.0,
                    ),
                  ))),
          Padding(
              //Posicion actual
              padding: EdgeInsets.only(top: width * 0.005),
              child: Material(
                color: Colors.transparent,
                child: Text(
                  positionText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: width / 20,
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
                      child: loopButton(width)),
                  Expanded(
                      //Atrás
                      flex: 15,
                      child: backButton(width)),
                  Expanded(
                      //Botones apilados (Play/Pause y Cola)
                      flex: 20,
                      child: Container(
                          height: width / 5,
                          child: Center(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                Expanded(
                                    //Play/Pause
                                    flex: 3,
                                    child: playPauseButton(width)),
                                Expanded(
                                  //Cola
                                  flex: 1,
                                  child: upNextButton(width),
                                )
                              ])))),
                  Expanded(
                      //Siguiente
                      flex: 15,
                      child: skipNextButton(width)),
                  Expanded(
                      //Favorita
                      flex: 10,
                      child: favButton(width))
                ],
              ))
        ]));
  }

  Widget extendedBottomBarControls(context) {
    double height = MediaQuery.of(context).size.height * 0.15;
    return Row(children: <Widget>[
      songImage(currentSong, height),
      Align(
          alignment: Alignment.centerRight,
          child: Row(children: <Widget>[
            backButton(height * 2),
            playPauseButton(height * 2),
            backButton(height * 2)
          ])),
      Expanded(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: height * 0.005),
              child: Material(
                  color: Colors.transparent,
                  child: slidingText(
                    condicion: true,
                    texto:
                        '${currentSong.title} - ${getSongArtists(currentSong.artists)}',
                    estilo: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: height / 6),
                  ))))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    allSongs.clear();
    buildPageLists(false);
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double ccPadding = MediaQuery.of(context).size.width / 12;
    return MultiProvider(
        providers: [
          StreamProvider<Duration>.value(
              initialData: Duration(),
              value: advancedPlayer.onAudioPositionChanged),
        ],
        child: onPlayerScreen
            ? WillPopScope(
                onWillPop: () async {
                  onPlayerScreen = false;
                  return true;
                },
                child: Stack(children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height,
                    child: PageView.builder(
                        itemCount: allSongs.length,
                        controller: _backController,
                        pageSnapping: false,
                        physics: new NeverScrollableScrollPhysics(),
                        itemBuilder: (context, int index) =>
                            fondo(allSongs[index])),
                  ),
                  BackdropFilter(
                    //Difuminado
                    filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      decoration: new BoxDecoration(
                          color: Colors.black54.withOpacity(0.5)),
                    ),
                  ),
                  Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                          padding: EdgeInsets.only(top: width / 20),
                          //Equis para cerrar

                          child: Material(
                              color: Colors.transparent,
                              child: IconButton(
                                  icon: Icon(
                                    CupertinoIcons.clear,
                                    size: 35,
                                  ),
                                  onPressed: () =>
                                      Navigator.of(context).pop())))),
                  Container(
                      height: MediaQuery.of(context).size.height - width * 0.5,
                      color: Colors.transparent,
                      child: Center(
                          child: Container(
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
                                      infoCancion(allSongs[index]))))),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: controls(width),
                  )
                ]))
            : extendedBottomBarControls(context));
  }
}
