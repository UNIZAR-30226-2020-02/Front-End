import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playstack/screens/Homescreen/PublicProfile.dart';
import 'package:playstack/services/database.dart';
import 'package:playstack/shared/Loading.dart';
import 'package:playstack/shared/common.dart';

class SearchPeople extends StatefulWidget {
  @override
  _SearchPeopleState createState() => _SearchPeopleState();
}

class _SearchPeopleState extends State<SearchPeople> {
  @override
  void initState() {
    super.initState();
  }

  final TextEditingController _searchController = new TextEditingController();

  Timer searchOnStoppedTyping;
  bool _loading = false;

  String _searchText = "";
  List names = new List();
  List filteredNames = new List();

  _SearchPeopleState() {
    _searchController.addListener(() {
      if (_searchController.text.isEmpty) {
        if (mounted)
          setState(() {
            _searchText = "";
            if (names.isNotEmpty) filteredNames = names;
          });
      } else {
        if (mounted)
          setState(() {
            _searchText = _searchController.text;
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
            if (_searchController.text != "") {
              setState(() {
                _loading = true;
              });
              names = await getUsers(value);
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
                  controller: _searchController,
                  decoration: new InputDecoration(
                      prefixIcon: new Icon(CupertinoIcons.search),
                      hintText: 'Buscar...',
                      hintStyle: TextStyle(color: Colors.white))),
            ),
          ],
        )),
        IconButton(
          icon: Icon(Icons.cancel),
          onPressed: () {
            previousIndex = homeIndex.value;
            homeIndex.value = 1; // Social
          },
        )
      ],
    );
  }

  Widget _buildList() {
    //Dejar esto asi aunque de warning, no pasa nada
    if (!(_searchText.isEmpty)) {
      List tempList = new List();
      for (int i = 0; i < filteredNames.length; i++) {
        if (filteredNames
            .elementAt(i)
            .title
            .toLowerCase()
            .contains(_searchText.toLowerCase())) {
          tempList.add(filteredNames.elementAt(i));
        }
      }
      filteredNames = tempList;
    }

    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: (names.length == 0) ? 0 : filteredNames.length,
      itemBuilder: (BuildContext context, int index) {
        return UserTile(user: filteredNames[index]);
      },
    );
  }

////////////////////////////////////////////////////////////////////////////
  /*  Widget _searchBar(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
            child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                  autofocus: true,
                  controller: _searchController,
                  decoration: new InputDecoration(
                      prefixIcon: new Icon(CupertinoIcons.search),
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: Colors.white))),
            ),
          ],
        )),
        IconButton(
          icon: _searched ? Icon(Icons.cancel) : Icon(Icons.search),
          onPressed: () async {
            if (_searched) {
              Navigator.of(context).pop();
            } else {
              if (mounted) {
                setState(() {
                  _loading = true;
                  _searched = !_searched;
                });
                users = await getUsers(_searchController.text);
                if (mounted)
                  setState(() {
                    _loading = false;
                  });
              }
            }
          },
        )
      ],
    );
  }

  Widget _buildList() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: users == null ? 0 : users.length,
      itemBuilder: (BuildContext context, int index) {
        return new ListTile(
          title: Text(users[index].title),
          onTap: () {
            viewingOwnPublicProfile = false;
            friendUserName = users[index].title;
            previousIndex = homeIndex.value;
            homeIndex.value = 6; // Perfil
          },
        );
      },
    );
  } */

}
