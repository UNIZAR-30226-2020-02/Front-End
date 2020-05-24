import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playstack/models/Genre.dart';
import 'package:playstack/models/Podcast.dart';
import 'package:playstack/models/Song.dart';
import 'package:playstack/services/database.dart';
import 'package:playstack/shared/Loading.dart';
import 'package:playstack/shared/common.dart';
import 'package:toast/toast.dart';

class YourPublicProfile extends StatefulWidget {
  YourPublicProfile();
  @override
  _YourPublicProfileState createState() => _YourPublicProfileState();
}

class _YourPublicProfileState extends State<YourPublicProfile> {
  bool _loading = true;
  bool _loadingMostListenedTo = true;
  bool _loadingFavouriteGenres = true;
  bool _loadingPublicPlaylists = true;
  bool _loadingLastListenedTo = true;

  bool alreadyFollowing = false;
  bool requestedFollow = false;

  String friendProfilePhoto;

  List likedGenres = new List();
  List publicPlaylists = new List();

  bool own = viewingOwnPublicProfile;

  @override
  void initState() {
    super.initState();
    if (!own) {
      friendName = friendUserName;
      if (otherUser == null) {
        getPhotoAndFollowStatus();
      } else {
        friendProfilePhoto = otherUser.photoUrl;
        checkFollowStatus();
      }
    } else {
      if (mounted)
        setState(() {
          _loading = false;
        });
    }
    getListsData('publicPlaylists');
    getListsData('lastListenedTo');
    getListsData('mostListenedTo');
    getListsData('likedGenres');
  }

  void getPhotoAndFollowStatus() async {
    friendProfilePhoto = await getForeignPicture(friendUserName);
    alreadyFollowing = await checkIfFollowing(friendUserName);
    if (mounted)
      setState(() {
        _loading = false;
      });
  }

  void getPhoto() async {
    friendProfilePhoto = await getForeignPicture(friendUserName);
  }

  void checkFollowStatus() async {
    alreadyFollowing = await checkIfFollowing(friendUserName);
    if (mounted)
      setState(() {
        _loading = false;
      });
  }

  Future<void> getListsData(String list) async {
    switch (list) {
      case 'mostListenedTo':
        songsMostListenedTo.clear();
        podcastsmostListenedTo.clear();
        if (!own) {
          await getMostListenedTo(friendUserName);
        } else {
          await getMostListenedTo(userName);
        }

        _loadingMostListenedTo = false;
        break;
      case 'likedGenres':
        if (!own) {
          likedGenres = await getFavouriteGenres(friendUserName);
        } else {
          likedGenres = await getFavouriteGenres(userName);
        }
        _loadingFavouriteGenres = false;
        break;
      case 'publicPlaylists':
        if (own) {
          publicPlaylists = await getpublicPlaylistsDB(own);
        } else {
          publicPlaylists =
              await getpublicPlaylistsDB(own, user: friendUserName);
        }
        _loadingPublicPlaylists = false;

        break;
      default:
        print("ultimas canciones y podcasts...");
        recentlyPlayedSongs.clear();
        recentlyPlayedPodcasts.clear();
        if (!own) {
          await getLastSongsListenedToDB(friendUserName);
        } else {
          await getLastSongsListenedToDB(userName);
        }
        _loadingLastListenedTo = false;
    }
    if (mounted) setState(() {});
  }

  Widget listItems(String list) {
    switch (list) {
      case 'mostListenedTo':
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount:
              songsMostListenedTo.isEmpty && podcastsmostListenedTo.isEmpty
                  ? 0
                  : songsMostListenedTo.length + podcastsmostListenedTo.length,
          itemBuilder: (BuildContext context, int index) {
            if (index < songsMostListenedTo.length) {
              Song tempSong = songsMostListenedTo[index];
              return SongTile(
                  song: tempSong,
                  songsList: songsMostListenedTo,
                  songsListName: own
                      ? "Más escuchadas de $userName"
                      : "Más escuchadas de $friendName");
            } else {
              Podcast tempSongPodcast = podcastsmostListenedTo[index];
              return PodcastItem(tempSongPodcast);
            }
          },
        );
        break;
      case 'likedGenres':
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: likedGenres.isEmpty ? 0 : likedGenres.length,
          itemBuilder: (BuildContext context, int index) {
            return new GenreTile(
              genre: likedGenres[index],
            );
          },
        );
        break;

      case 'publicPlaylists':
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: publicPlaylists.isEmpty ? 0 : publicPlaylists.length,
          itemBuilder: (BuildContext context, int index) {
            return new PlaylistTile(
              playlist: publicPlaylists[index],
              isOwn: own,
            );
          },
        );
        break;

      case "lastSongs":
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount:
              recentlyPlayedSongs.isEmpty ? 0 : recentlyPlayedSongs.length,
          itemBuilder: (BuildContext context, int index) {
            return SongTile(
                song: recentlyPlayedSongs[index],
                songsList: recentlyPlayedSongs,
                songsListName: "Reproducidas recientemente");
          },
        );

        break;
      default:
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: recentlyPlayedPodcasts.isEmpty
              ? 0
              : recentlyPlayedPodcasts.length,
          itemBuilder: (BuildContext context, int index) {
            return PodcastItem(recentlyPlayedPodcasts[index]);
          },
        );
    }
  }

  Widget followButton(BuildContext context) {
    return !own
        ? Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Container(
              height: 35.0,
              width: MediaQuery.of(context).size.width / 3,
              child: RaisedButton(
                onPressed: () async {
                  if (!alreadyFollowing) {
                    bool sent = await sendFollowRequest(friendUserName);
                    if (sent) {
                      if (mounted)
                        setState(() {
                          requestedFollow = true;
                        });
                      Toast.show("Solicitud enviada!", context,
                          gravity: Toast.CENTER,
                          backgroundColor: Colors.green[600],
                          duration: Toast.LENGTH_LONG);
                    } else {
                      Toast.show("No se pudo enviar la solicitud", context,
                          gravity: Toast.CENTER,
                          backgroundColor: Colors.red[600],
                          duration: Toast.LENGTH_LONG);
                    }
                  } else {
                    bool res = await unfollow(friendUserName);
                    if (res) {
                      if (mounted)
                        setState(() {
                          alreadyFollowing = false;
                        });
                    } else {
                      Toast.show(
                          "Error dejando de seguir a $friendUserName", context,
                          gravity: Toast.CENTER,
                          backgroundColor: Colors.red[600],
                          duration: Toast.LENGTH_LONG);
                    }
                  }
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(80.0)),
                padding: EdgeInsets.all(0.0),
                child: Ink(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red[800],
                          Colors.red[300],
                          Colors.red[800]
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Container(
                    constraints:
                        BoxConstraints(maxWidth: 300.0, minHeight: 50.0),
                    alignment: Alignment.center,
                    child:
                        Text(alreadyFollowing ? "Dejar de seguir" : "Seguir"),
                  ),
                ),
              ),
            ),
          )
        : Text('');
  }

  Widget cancelFollowButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
        height: 40.0,
        width: MediaQuery.of(context).size.width / 3,
        child: RaisedButton(
          onPressed: () async {
            bool res = await removeFollowRequest(friendUserName);
            if (res) {
              Toast.show("Solicitud de amistad cancelada", context,
                  gravity: Toast.CENTER,
                  duration: Toast.LENGTH_LONG,
                  backgroundColor: Colors.grey);
              if (mounted)
                setState(() {
                  requestedFollow = false;
                });
            } else {
              Toast.show("No se pudo cancelar la solicitud de amistad", context,
                  gravity: Toast.CENTER,
                  duration: Toast.LENGTH_LONG,
                  backgroundColor: Colors.grey);
            }
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
          padding: EdgeInsets.all(0.0),
          child: Ink(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange[800],
                    Colors.orange[300],
                    Colors.orange[800]
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(10.0)),
            child: Container(
              constraints: BoxConstraints(maxWidth: 300.0, minHeight: 50.0),
              alignment: Alignment.center,
              child: Text("Cancelar solicitud"),
            ),
          ),
        ),
      ),
    );
  }

  Widget photoAndButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Center(
          child: Column(
        children: <Widget>[
          Text(
            own ? userName : friendUserName,
            style: TextStyle(fontSize: 25),
          ),
          SizedBox(height: 10),
          own
              ? ProfilePicture()
              : CircleAvatar(
//backgroundColor: Color(0xFF191414),
                  radius: 60,
                  backgroundImage: NetworkImage(friendProfilePhoto)),
          requestedFollow ? cancelFollowButton(context) : followButton(context),
        ],
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
                leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      int temp = homeIndex.value;
                      homeIndex.value = previousIndex;
                      previousIndex = temp;
                    }),
                centerTitle: true,
                title: Text('Tu perfil')),
            body: ListView(
              children: <Widget>[
                photoAndButtons(),
                own || alreadyFollowing
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Center(
                              child: Text("Canciones más escuchadas",
                                  style: TextStyle(fontSize: 20),
                                  textAlign: TextAlign.center),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 8),
                              child: playlistsDivider(),
                            ),
                            _loadingMostListenedTo
                                ? Center(child: LoadingSongs())
                                : songsMostListenedTo.isEmpty &&
                                        podcastsmostListenedTo.isEmpty
                                    ? Center(
                                        child: Text(
                                            "Ninguna canción o podcast escuchado"))
                                    : Container(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                5,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: listItems('mostListenedTo')),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Center(
                                child: Text("Géneros más escuchados",
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                    textAlign: TextAlign.center),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 8),
                              child: playlistsDivider(),
                            ),
                            _loadingFavouriteGenres
                                ? Center(child: LoadingSongs())
                                : likedGenres.isEmpty
                                    ? Center(
                                        child: Text("Ninguna género escuchado"))
                                    : Container(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                5,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: listItems('likedGenres')),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Center(
                                child: Text("Listas de reproducción públicas",
                                    style: TextStyle(fontSize: 20),
                                    textAlign: TextAlign.center),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 8),
                              child: playlistsDivider(),
                            ),
                            _loadingPublicPlaylists
                                ? Center(child: LoadingSongs())
                                : publicPlaylists.isEmpty
                                    ? Center(
                                        child: Text(
                                            "Ninguna lista de reproducción pública"))
                                    : Container(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                5,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: listItems('publicPlaylists')),
                            Center(
                              child: Text("Últimas canciones escuchadas",
                                  style: TextStyle(fontSize: 20),
                                  textAlign: TextAlign.center),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: playlistsDivider(),
                            ),
                            _loadingLastListenedTo
                                ? Center(child: LoadingSongs())
                                : recentlyPlayedSongs.isEmpty
                                    ? Center(
                                        child:
                                            Text("Ninguna canción escuchada"))
                                    : Container(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                5,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: listItems('lastSongs')),
                            Center(
                              child: Text("Últimos podcast escuchados",
                                  style: TextStyle(fontSize: 20),
                                  textAlign: TextAlign.center),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 8),
                              child: playlistsDivider(),
                            ),
                            _loadingLastListenedTo
                                ? Center(child: LoadingSongs())
                                : recentlyPlayedPodcasts.isEmpty
                                    ? Center(
                                        child:
                                            Text("Ningun o podcast escuchado"))
                                    : Container(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                5,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: listItems('lastPodcasts')),
                          ],
                        ),
                      )
                    : Text(''),
              ],
            ),
          );
  }

  /* @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Color(0xFF191414),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          bottomOpacity: 1.0,
          bottom: TabBar(
            indicatorColor: Colors.orange[800],
            tabs: [
              Tab(
                child: Text(
                  'Canciones y podcasts más escuchados',
                  style: TextStyle(fontFamily: 'Circular', fontSize: 20),
                ),
              ),
              Tab(
                child: Text(
                  'Géneros más escuchados',
                  style: TextStyle(fontFamily: 'Circular', fontSize: 20),
                ),
              ),
              Tab(
                child: Text(
                  'Listas de reproducción públicas',
                  style: TextStyle(fontFamily: 'Circular', fontSize: 20),
                ),
              ),
              Tab(
                child: Text(
                  'Últimas canciones y podcast escuchados',
                  style: TextStyle(fontFamily: 'Circular', fontSize: 20),
                ),
              ),
            ],
          ),
          title: Text(
            "Perfil",
            style: TextStyle(fontFamily: 'Circular'),
          ),
        ),
        body: Scaffold(
          backgroundColor: Colors.transparent,
          body: TabBarView(
            children: [
              _loadingMostListenedTo
                  ? LoadingSongs()
                  : mostListenedTo.isEmpty
                      ? Center(
                          child: Text("Ninguna canción o podcast escuchado"))
                      : Column(
                          children: <Widget>[
                            _loading ? LoadingOthers() : photoAndButtons(),
                            listItems('mostListenedTo'),
                          ],
                        ),
              _loadingFavouriteGenres
                  ? LoadingSongs()
                  : likedGenres.isEmpty
                      ? Center(child: Text("Ninguna género escuchado"))
                      : Column(
                          children: <Widget>[
                            _loading ? LoadingOthers() : photoAndButtons(),
                            listItems('likedGenres'),
                          ],
                        ),
              _loadingPublicPlaylists
                  ? LoadingSongs()
                  : publicPlaylists.isEmpty
                      ? Center(
                          child: Text("Ninguna lista de reproducción pública"))
                      : Column(
                          children: <Widget>[
                            _loading ? LoadingOthers() : photoAndButtons(),
                            listItems('publicPlaylists'),
                          ],
                        ),
              _loadingLastListenedTo
                  ? LoadingSongs()
                  : lastListenedTo.isEmpty
                      ? Center(
                          child: Text("Ninguna canción o podcast escuchado"))
                      : Column(
                          children: <Widget>[
                            _loading ? LoadingOthers() : photoAndButtons(),
                            listItems('lastListenedTo'),
                          ],
                        ),
            ],
          ),
        ),
      ),
    );
  } */
}
