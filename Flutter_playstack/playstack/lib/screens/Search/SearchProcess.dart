import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:playstack/services/database.dart';
import 'package:playstack/shared/common.dart';

class SearchProcess extends StatefulWidget {
  @override
  _SearchProcessState createState() => _SearchProcessState();
}

class _SearchProcessState extends State<SearchProcess> {
  final TextEditingController _filter = new TextEditingController();
  final dio = new Dio();
  String _searchText = "";
  List names = new List();
  List filteredNames = new List();

  _SearchProcessState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
          filteredNames = names;
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }

  @override
  void initState() {
    this._getSongs();
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
            _buildList(),
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
                  controller: _filter,
                  decoration: new InputDecoration(
                      prefixIcon: new Icon(CupertinoIcons.search),
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: Colors.black))),
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
      for (int i = 0; i < filteredNames.length; i++) {
        if (filteredNames[i]['name']
            .toLowerCase()
            .contains(_searchText.toLowerCase())) {
          tempList.add(filteredNames[i]);
        }
      }
      filteredNames = tempList;
    }
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: names == null ? 0 : filteredNames.length,
      itemBuilder: (BuildContext context, int index) {
        return new SongItem(
            filteredNames[index], new List(), filteredNames[index].title);
      },
    );
  }

  void _getSongs() async {
    List allsongs = await getAllSongs();

    setState(() {
      names = allsongs;
      names.shuffle();
      filteredNames = names;
    });
  }
}
