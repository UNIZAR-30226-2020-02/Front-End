import 'dart:io';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:playstack/models/Audio.dart';
import 'package:flutter/foundation.dart';
import 'package:playstack/models/Song.dart';
import 'package:playstack/screens/Player/PlayingNow.dart';
import 'package:playstack/shared/Loading.dart';
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
  bool _loopEnabled = false;
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

  @override
  void initState() {
    _initAudioPlayer();

    print("Url de la cancion: " + currentAudio.url);
    advancedPlayer.seekCompleteHandler =
        (finished) => setState(() => seekDone = finished);
    _showCover = false;
    _loopEnabled = false;
    _pageController.addListener(() {
      _backController.jumpTo(_pageController.offset);
      print(absoluteChangeInPage);
      if ((_pageController.page - currentPage).abs() > 0.99) {
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

    super.initState();
  }

  void _initAudioPlayer() {
    if (!playerActive) {
      playerActive = true;
      advancedPlayer.mode = mode;

      durationSubscription = advancedPlayer.onDurationChanged.listen((value) {
        if (mounted) setState(() => duration = value);
/*
        // Para que aparezca en la barra de notificaciones la reproducción, sólo implementado para iOS
        if (Theme.of(context).platform == TargetPlatform.iOS) {
          // (Optional) listen for notification updates in the background
          advancedPlayer.startHeadlessService();

          // set at least title to see the notification bar on ios.
          advancedPlayer.setNotification(
              title: 'PlayStack',
              artist: 'Artist or blank',
              albumTitle: 'Name or blank',
              imageUrl: 'url or blank',
              forwardSkipInterval:
                  const Duration(seconds: 30), // default is 30s
              backwardSkipInterval:
                  const Duration(seconds: 30), // default is 30s
              duration: duration,
              elapsedTime: Duration(seconds: 0));
        }*/
      });

      // Listener para actualizar la posición de la canción
      positionSubscription = advancedPlayer.onAudioPositionChanged.listen((p) {
        if (mounted)
          setState(() {
            position = p;
          });
      });

      // Listener para cuando acabe
      playerCompleteSubscription =
          advancedPlayer.onPlayerCompletion.listen((event) {
        _onComplete();
        setState(() {
          position = duration;
        });
        skipSong(true);
      });

      playerErrorSubscription = advancedPlayer.onPlayerError.listen((msg) {
        print('advancedPlayer error : $msg');
        setState(() {
          playerState = PlayerState.stopped;
          //duration = Duration(seconds: 0);
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

/*   Future<bool> errorInSong() async {
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
  } */

  void _onComplete() {
    setState(() => playerState = PlayerState.stopped);
  }

  void buildPageLists(bool onlyNext) {
    if (!onlyNext) {
      allAudios.addAll(songsPlayed);
      allAudios.add(currentAudio);
    }
    allAudios.addAll(songsNextUp);
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
    final playposition = (position != null &&
            duration != null &&
            position.inMilliseconds > 0 &&
            position.inMilliseconds < duration.inMilliseconds)
        ? position
        : Duration.zero;
    print('Duration: ${duration}, position.value: ${position}');
    final result = await advancedPlayer.play(currentAudio.url,
        position: playposition, isLocal: currentAudio.isLocal);
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

  /*  @override
  void dispose() {
    /*advancedPlayer.stop();
    durationSubscription?.cancel();
    position.valueSubscription?.cancel();
    playerCompleteSubscription?.cancel();
    playerErrorSubscription?.cancel();
    audioPlayerStateSubscription?.cancel();
    */
    super.dispose();
  } */

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
      }
      currentAudio.markAsListened();
      currentPage -= 1;
      if (mustScroll) {
        Future.delayed(
            Duration(milliseconds: 400), () => _usingButtons = false);
      }

      position = Duration.zero;
      //duration = Duration(seconds: 0);
      //Navigator.of(context).pushReplacement(MaterialPageRoute(
      //    builder: (BuildContext context) => PlayingNowScreen()));

    }
  }

  void removeDupes(List<Audio> list) {
    int i = 0;
    while (i < list.length) {
      int j = i + 1;
      while (j < list.length) {
        Audio el1 = list.elementAt(i);
        Audio el2 = list.elementAt(j);
        if (el1.title == el2.title &&
            el1.artists == el2.artists &&
            !el1.isLocal &&
            !el2.isLocal) {
          list.remove(j);
        }
        j++;
      }
      i++;
    }
  }

  void skipSong(bool mustScroll) {
    print("Skipping ($currentPage/${allAudios.length})");

    if (songsNextUp.isNotEmpty || _loopEnabled) {
      if (isPlaying) mustPause.value = true;
      if (songsNextUp.isNotEmpty) {
        if (mounted) {
          setState(() {
            songsPlayed.add(currentAudio);
            currentAudio = songsNextUp.first;
            songsNextUp.removeAt(0);
          });
        } else {
          songsPlayed.add(currentAudio);
          currentAudio = songsNextUp.first;
          songsNextUp.removeAt(0);
        }
      } else {
        songsNextUp.addAll(allAudios);
        removeDupes(songsNextUp);
        if (shuffleEnabled) {
          songsNextUp.shuffle();
        }
        buildPageLists(true);
        songsPlayed.add(currentAudio);
        currentAudio = songsNextUp.first;
        songsNextUp.removeAt(0);
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
      }
      currentPage += 1;
      currentAudio.markAsListened();
      position = Duration(seconds: 0);

      if (mustScroll) {
        Future.delayed(
            Duration(milliseconds: 400), () => _usingButtons = false);
      }
      position = Duration.zero;
      //duration = Duration(seconds: 0);

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
    return Padding(
      padding: EdgeInsets.all(width * 0.01),
      child: Container(
        height: width * 0.7,
        width: width * 0.7,
        decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8.0),
            image: DecorationImage(
                image: audio.albumCoverUrls.isNotEmpty
                    ? NetworkImage(audio.albumCoverUrls.elementAt(0))
                    : Image.asset("assets/images/defaultCover.png").image,
                fit: BoxFit.cover)),
      ),
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
                          texto: currentAudio.isLocal
                              ? ''
                              : getSongArtists(audio.artists),
                          condicion: currentAudio.isLocal
                              ? false
                              : audio.artists.length * 24.50 > width,
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
        child: audio.albumCoverUrls.isEmpty
            ? Image.asset(
                'assets/images/defaultCover.png',
                fit: BoxFit.fitWidth,
                width: MediaQuery.of(context).size.width,
              )
            : Image.network(audio.albumCoverUrls.elementAt(0),
                fit: BoxFit.fitHeight));
  }

  Widget nextOrBackButton(double width, bool back) {
    return Container(
        height: width / 5,
        child: Center(
            child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  child: Icon(
                    back ? Icons.skip_previous : Icons.skip_next,
                    color: Colors.white.withOpacity(0.8),
                    size: width / 8.82,
                  ),
                  onTap: () {
                    _usingButtons = true;
                    back ? skipPrevious(true) : skipSong(true);
                  },
                ))));
  }

  Widget playPauseButton(double width) {
    return Material(
        color: Colors.transparent,
        child: FloatingActionButton(
          backgroundColor: Colors.grey.withOpacity(0.6),
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

  Widget shuffleButton(double width) {
    return Container(
        height: width / 10,
        child: Center(
            child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  child: Icon(
                    Icons.shuffle,
                    color: shuffleEnabled
                        ? Colors.red
                        : Colors.white.withOpacity(0.8),
                    size: width / 17.62,
                  ),
                  onTap: () => setState(() => shuffleEnabled = !shuffleEnabled),
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
                      currentAudio.runtimeType == Song
                          ? currentAudio.isFav
                              ? Icons.favorite
                              : Icons.favorite_border
                          : currentAudio.isFav
                              ? Icons.notifications_active
                              : Icons.notifications_none,
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
                        final tmpPosition = v * duration.inMilliseconds;
                        advancedPlayer
                            .seek(Duration(milliseconds: tmpPosition.round()));
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
                    position != null
                        ? '${positionText ?? ''} / ${durationText ?? ''}'
                        : duration != null ? durationText : '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: width / 20,
                        color: Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0),
                  ))),
          Padding(
              //SECCION DE BOTONES
              padding: EdgeInsets.fromLTRB(
                  width * 0.05, width * 0.05, width * 0.05, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                      flex: 10,
                      child: Column(
                        children: <Widget>[
                          loopButton(width),
                          shuffleButton(width)
                        ],
                      )
                      //Bucle

                      ),
                  Expanded(
                      //Atrás
                      flex: 15,
                      child: nextOrBackButton(width, true)),
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
                      child: currentAudio.isLocal ? Text("") : favButton(width))
                ],
              ))
        ]));
  }

  Widget extendedBottomBarControls(context) {
    double height = MediaQuery.of(context).size.height * 0.15;
    double width = MediaQuery.of(context).size.width;
    return Stack(children: <Widget>[
      Container(
        color: Colors.grey[900],
        child: Row(children: <Widget>[
          songImage(currentAudio, height),
          Align(
              alignment: Alignment.centerRight,
              child: Row(children: <Widget>[
                nextOrBackButton(height * 2, true),
                playPauseButton(height * 2),
                nextOrBackButton(height * 2, false)
              ])),
          Expanded(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: height * 0.005),
                  child: Material(
                      color: Colors.transparent,
                      child: slidingText(
                        condicion: true,
                        texto: currentAudio.isLocal
                            ? '${currentAudio.title}'
                            : '${currentAudio.title} - ${getSongArtists(currentAudio.artists)}',
                        estilo: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: height / 6),
                      ))))
        ]),
      ),
      Align(
          alignment: Alignment.centerLeft,
          child: Container(
              width: height * 0.75,
              height: height,
              color: Colors.transparent,
              child: GestureDetector(onTap: () {
                onPlayerScreen = true;
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => PlayingNowScreen()));
              }))),
      Align(
          alignment: Alignment.centerRight,
          child: Container(
              height: height,
              width: width - height * 1.65,
              color: Colors.transparent,
              child: GestureDetector(onTap: () {
                onPlayerScreen = true;
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => PlayingNowScreen()));
              }))),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    super.build(context);
    return MultiProvider(
        providers: [
          StreamProvider<Duration>.value(
              initialData: Duration(),
              value: advancedPlayer.onAudioPositionChanged),
        ],
        child: ValueListenableBuilder(
          valueListenable: mustPause,
          builder: (context, value, child) {
            if (mustPause.value && isPlaying) {
              togglePlayPause();
              position = Duration.zero;
            }
            if (mustPause.value) {
              Future.delayed(Duration(milliseconds: 900), () {
                if (!isPlaying) togglePlayPause();
              });
            }
            print("Buildea el player");
            mustPause.value = false;
            return onPlayerScreen
                ? (currentAudio != null
                    ? WillPopScope(
                        onWillPop: () async {
                          onPlayerScreen = false;
                          if (currentIndex.value == 3) currentIndex.value = 0;
                          notifyAllListeners();
                          audioIsNull.value = false;
                          return false;
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
                            filter:
                                ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                            child: Container(
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              decoration: new BoxDecoration(
                                  color: Colors.black54.withOpacity(0.5)),
                            ),
                          ),
                          Container(
                              height: MediaQuery.of(context).size.height -
                                  width * 0.5,
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
                                        notifyAllListeners();
                                        audioIsNull.value = false;
                                        //Navigator.of(context).pop();
                                      }))),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: controls(width),
                          )
                        ]))
                    : Loading())
                : extendedBottomBarControls(context);
          },
        ));
  }
}
