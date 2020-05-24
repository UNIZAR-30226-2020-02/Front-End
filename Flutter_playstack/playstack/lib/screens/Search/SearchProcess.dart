import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playstack/models/Album.dart';
import 'package:playstack/models/Artist.dart';
import 'package:playstack/services/database.dart';
import 'package:playstack/shared/Loading.dart';
import 'package:playstack/shared/common.dart';

class SearchProcess extends StatefulWidget {
  @override
  _SearchProcessState createState() => _SearchProcessState();
}

class _SearchProcessState extends State<SearchProcess> {
  final TextEditingController _filter = new TextEditingController();

  Timer searchOnStoppedTyping;

  String _searchText = "";
  List names = new List();
  List filteredNames = new List();
  bool _loading = false;

  _SearchProcessState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        if (mounted)
          setState(() {
            _searchText = "";
            if (names.isNotEmpty)
              filteredNames = names;
            else
              for (var i = 0; i < 5; i++) {
                List newList = new List();
                filteredNames.add(newList);
              }
          });
      } else {
        if (mounted)
          setState(() {
            _searchText = _filter.text;
          });
      }
    });
  }

  _onChangeHandler(value) {
    const duration = Duration(
        seconds: 1); // set the duration that you want call search() after that.
    if (searchOnStoppedTyping != null) {
      if (mounted)
        setState(() => searchOnStoppedTyping.cancel()); // clear timer
    }
    if (mounted)
      setState(() => searchOnStoppedTyping = new Timer(duration, () async {
            if (_filter.text != "") {
              setState(() {
                _loading = true;
              });
              names = await search(value);
              setState(() {
                _loading = false;
              });
            }
            if (mounted)
              setState(() {
                filteredNames = names;
              });
          }));
  }

  @override
  void initState() {
    for (var i = 0; i < 5; i++) {
      List newList = new List();
      filteredNames.add(newList);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF191414),
      //appBar: _buildBar(context),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 20, 15, 0),
        child: ListView(
          children: <Widget>[
            _searchBar(context),
            _loading ? LoadingSongs() : _buildList(),
          ],
        ),
      ),
      resizeToAvoidBottomPadding: false,
    );
  }

  Widget _searchBar(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
            child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                  autofocus: true,
                  onChanged: _onChangeHandler,
                  controller: _filter,
                  decoration: new InputDecoration(
                      prefixIcon: new Icon(CupertinoIcons.search),
                      hintText: 'Buscar...',
                      hintStyle: TextStyle(color: Colors.white))),
            ),
          ],
        )),
        IconButton(
            icon: Icon(Icons.cancel),
            onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }

  Widget _buildList() {
    //Dejar esto asi aunque de warning, no pasa nada
    if (!(_searchText.isEmpty)) {
      List tempList = new List();
      for (var i = 0; i < 5; i++) {
        List newList = new List();
        tempList.add(newList);
      }
      for (int i = 0; i < filteredNames.length; i++) {
        for (var j = 0; j < filteredNames.elementAt(i).length; j++) {
          if (filteredNames
              .elementAt(i)
              .elementAt(j)
              .title
              .toLowerCase()
              .contains(_searchText.toLowerCase())) {
            tempList.elementAt(i).add(filteredNames.elementAt(i).elementAt(j));
          }
        }
      }
      filteredNames = tempList;
    }
    if (filteredNames.length < 5) {
      for (var i = 0; i < 5; i++) {
        List newList = new List();
        filteredNames.add(newList);
      }
    }
    List _songs = filteredNames.elementAt(0);
    List _playlists = filteredNames.elementAt(1);
    List _albums = filteredNames.elementAt(2);
    List _podcasts = filteredNames.elementAt(3);
    List _artists = filteredNames.elementAt(4);
    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: (names.length == 0)
          ? 0
          : (_songs.length +
              _playlists.length +
              _albums.length +
              _podcasts.length +
              _artists.length),
      itemBuilder: (BuildContext context, int index) {
        if (index < _songs.length) {
          return new SongItem(
            _songs.elementAt(index),
            new List(),
            _songs.elementAt(index).title,
            isNotOwn: true,
          );
        } else if (index < (_songs.length + _playlists.length)) {
          return new PlaylistItem(
            _playlists.elementAt(index - _songs.length),
            false,
          );
        } else if (index <
            (_songs.length + _playlists.length + _albums.length)) {
          return new AlbumTile(
              _albums[index - (_songs.length + _playlists.length)]);
        } else if (index <
            (_songs.length +
                _playlists.length +
                _albums.length +
                _podcasts.length)) {
          return new PodcastTile(_podcasts[
              index - (_songs.length + _playlists.length + _albums.length)]);
        } else if (index <
            (_songs.length +
                _playlists.length +
                _albums.length +
                _podcasts.length +
                _artists.length)) {
          return new ArtistTile(_artists[index -
              (_songs.length +
                  _playlists.length +
                  _albums.length +
                  _podcasts.length)]);
        }
      },
    );
  }
}
