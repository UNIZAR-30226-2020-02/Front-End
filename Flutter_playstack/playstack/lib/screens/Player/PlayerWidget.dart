import 'dart:io';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:playstack/models/Audio.dart';
import 'package:playstack/screens/mainscreen.dart';
import 'package:flutter/foundation.dart';
import 'package:playstack/models/Song.dart';
import 'package:playstack/shared/Loading.dart';
import 'package:playstack/shared/common.dart';
import 'package:playstack/screens/Player/UpNext.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

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
  bool _loopEnabled = false;
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
      playerActive = true;
      advancedPlayer.mode = mode;

      durationSubscription = advancedPlayer.onDurationChanged.listen((value) {
        setState(() => duration = value);

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
                position.value = p;
              }));

      // Listener para cuando acabe
      playerCompleteSubscription =
          advancedPlayer.onPlayerCompletion.listen((event) {
        if (position.value >= duration) {
          //_onComplete();
          //setState(() {
          //  position.value = duration;
          //});
          skipSong(true);
        }
      });

      playerErrorSubscription = advancedPlayer.onPlayerError.listen((msg) {
        print('advancedPlayer error : $msg');
        setState(() {
          audioPlayerState = AudioPlayerState.STOPPED;
          position.value = Duration(seconds: 0);
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

  Future<bool> errorInSong() async {
    dynamic error = await Future.doWhile(() => currentAudio == null)
        .timeout(Duration(seconds: 5), onTimeout: () {
      if (currentAudio == null) {
        onPlayerScreen = false;
        Toast.show(languageStrings['cantPlaySong'], context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        return true;
      } else {
        return false;
      }
    });
    return !(error == null);
  }

  @override
  void initState() {
    if (errorInSong() != null) {
      print("Url de la cancion: " + currentAudio.url);
      advancedPlayer.seekCompleteHandler =
          (finished) => setState(() => seekDone = finished);
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
      if (audioPlayerState != AudioPlayerState.PLAYING && !playerActive) {
        togglePlayPause();
      }
      playerActive = true;
    } else {
      Navigator.of(context).pop();
    }
    super.initState();
  }

  void _onComplete() {
    setState(() => audioPlayerState = AudioPlayerState.STOPPED);
  }

  void buildPageLists(bool onlyNext) {
    if (!onlyNext) {
      songsPlayed.forEach((value) {
        allAudios.add(value);
      });

      allAudios.add(currentAudio);
    }

    songsNextUp.forEach((value) {
      allAudios.add(value);
    });
  }

  Future<int> _pause() async {
    final result = await advancedPlayer.pause();
    if (result == 1) setState(() => audioPlayerState = AudioPlayerState.PAUSED);
    return result;
  }

  Future<int> _stop() async {
    final result = await advancedPlayer.stop();
    if (result == 1) {
      setState(() {
        audioPlayerState = AudioPlayerState.STOPPED;
        position.value = Duration();
      });
    }
    return result;
  }

  Future<int> _play() async {
    final playposition = (position.value != null &&
            duration != null &&
            position.value.inMilliseconds > 0 &&
            position.value.inMilliseconds < duration.inMilliseconds)
        ? position.value
        : Duration.zero;
    print('Duration: ${duration}, position.value: ${position.value}');
    final result =
        await advancedPlayer.play(currentAudio.url, position: playposition);
    if (result == 1)
      setState(() => audioPlayerState = AudioPlayerState.PLAYING);

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
    position.valueSubscription?.cancel();
    playerCompleteSubscription?.cancel();
    playerErrorSubscription?.cancel();
    audioPlayerStateSubscription?.cancel();
    */
    super.dispose();
  }

  void skipPrevious(bool mustScroll) {
    if (songsPlayed.isNotEmpty) {
      if (isPlaying) {
        togglePlayPause();
      }

      setState(() {
        songsNextUp.insert(0, currentAudio);
        currentAudio = songsPlayed.last;
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
      currentAudio.markAsListened();
      position.value = Duration(seconds: 0);
      duration = Duration(seconds: 0);
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
          songsPlayed.add(currentAudio);
          currentAudio = songsNextUp.first;
          songsNextUp.removeAt(0);
        });
      } else {
        songsNextUp = allAudios;
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
      currentAudio.markAsListened();
      position.value = Duration(seconds: 0);
      duration = Duration(seconds: 0);
      Future.delayed(Duration(milliseconds: mustScroll ? 900 : 500), () {
        if (!isPlaying) togglePlayPause();
      });

      //Navigator.of(context).pushReplacement(MaterialPageRoute(
      //    builder: (BuildContext context) => PlayingNowScreen()));

    }
  }

  dynamic getImage(Audio audio) {
    if (audio.albumCoverUrls == null) return null;
    return audio == null
        ? null
        : new File.fromUri(Uri.parse(audio.albumCoverUrls.elementAt(0)));
  }

  initAnim() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {
              _animateIcon = Tween<double>(begin: 0.0, end: 1.0)
                  .animate(_animationController);
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
            });
          });
    setState(() {
      _animateIcon =
          Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    });
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

  Widget songImage(Audio audio, double width) {
    return Container(
      height: width * 0.8,
      width: width * 0.8,
      decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
          image: DecorationImage(
              image: audio.albumCoverUrls.elementAt(0) != null
                  ? NetworkImage(audio.albumCoverUrls.elementAt(0))
                  : Image.asset("assets/images/defaultCover.png").image,
              fit: BoxFit.cover)),
    );
  }

  Widget infoCancion(Audio audio) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            //Carátula
            padding: EdgeInsets.only(top: width / 50),
            child: songImage(audio, width),
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
                              texto: '${audio.title}',
                              condicion: audio.title.length * 18.40 > width,
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
                          texto: getSongArtists(audio.artists),
                          condicion: audio.artists.length * 24.50 > width,
                          estilo: new TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: width / 24.50,
                              letterSpacing: width / 245,
                              height: width / 294))))),
        ]);
  }

  Widget fondo(Audio audio) {
    return Container(
        //Fondo
        height: MediaQuery.of(context).size.height,
        child: audio.albumCoverUrls == null
            ? Image.asset(
                'assets/images/defaultCover.png',
                fit: BoxFit.fitWidth,
                width: MediaQuery.of(context).size.width,
              )
            : Image.network(audio.albumCoverUrls.elementAt(0),
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
                      currentAudio.isFav
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: currentAudio.isFav
                          ? Colors.red
                          : Colors.white.withOpacity(0.8),
                      size: width / 17.62,
                    ),
                    onTap: () async {
                      if (currentAudio.isFav) {
                        await currentAudio.removeFromFavs();
                        setState(() {});
                      } else {
                        await currentAudio.setAsFav();
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
                        /*position.value = Duration(
                            milliseconds:
                                (v * duration.inMilliseconds).round());
                        var temp = await advancedPlayer.getDuration();
                        if (temp > position.value.inMilliseconds) {
                          print(temp.toString());
                          advancedPlayer.seek(Duration(
                              milliseconds:
                                  position.value.inMilliseconds.round()));
                        }*/
                      },
                      value: (position.value != null &&
                              duration != null &&
                              position.value.inMilliseconds > 0 &&
                              position.value.inMilliseconds <
                                  duration.inMilliseconds)
                          ? position.value.inMilliseconds /
                              duration.inMilliseconds
                          : 0.0,
                    ),
                  ))),
          Padding(
              //Posicion actual
              padding: EdgeInsets.only(top: width * 0.005),
              child: Material(
                  color: Colors.transparent,
                  child: ValueListenableBuilder(
                      valueListenable: position,
                      builder:
                          (BuildContext context, Duration value, Widget child) {
                        return Text(
                          positionText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: width / 20,
                              color: Colors.white.withOpacity(0.6),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0),
                        );
                      }))),
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
      songImage(currentAudio, height),
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
                        '${currentAudio.title} - ${getSongArtists(currentAudio.artists)}',
                    estilo: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: height / 6),
                  ))))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    _initAudioPlayer();
    width = MediaQuery.of(context).size.width;
    allAudios.clear();
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
            ? (currentAudio != null
                ? WillPopScope(
                    onWillPop: () async {
                      onPlayerScreen = false;
                      if (currentIndex.value == 3) currentIndex.value = 0;
                      return true;
                    },
                    child: Stack(children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height,
                        child: PageView.builder(
                            itemCount: allAudios.length,
                            controller: _backController,
                            pageSnapping: false,
                            physics: new NeverScrollableScrollPhysics(),
                            itemBuilder: (context, int index) =>
                                fondo(allAudios[index])),
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
                      Container(
                          height:
                              MediaQuery.of(context).size.height - width * 0.5,
                          color: Colors.transparent,
                          child: Center(
                              child: Container(
                                  height: width * 0.9905,
                                  child: PageView.builder(
                                      itemCount: allAudios.length,
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
                                          infoCancion(allAudios[index]))))),
                      Positioned(
                          top: width / 20,
                          //Equis para cerrar
                          child: Material(
                              color: Colors.transparent,
                              child: IconButton(
                                  icon: Icon(
                                    CupertinoIcons.clear,
                                    size: 35,
                                  ),
                                  onPressed: () {
                                    onPlayerScreen = false;
                                    if (currentIndex.value == 3)
                                      currentIndex.value = 0;
                                    Navigator.of(context).pop();
                                  }))),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: controls(width),
                      )
                    ]))
                : Loading())
            : extendedBottomBarControls(context));
  }
}
