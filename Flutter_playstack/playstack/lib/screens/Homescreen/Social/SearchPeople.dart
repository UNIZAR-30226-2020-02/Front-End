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
  final TextEditingController _searchController = new TextEditingController();

  String _searchText = "";

  bool _searched = false;
  bool _loading = true;

  List users = new List();

  @override
  void initState() {
    super.initState();
    getAllUsers();
  }

  void getAllUsers() async {
    users = await getUsers("");
    print("Recopilados todos los usuarios");
    if (!leftAlready) setState(() {});
  }

  _SearchPeopleState() {
    _searchController.addListener(() {
      if (_searchController.text.isEmpty) {
        if (!leftAlready) {
          setState(() {
            _searched = false;
            _searchText = "";
          });
        }
      } else {
        if (!leftAlready) {
          setState(() {
            _searched = false;
            _searchText = _searchController.text;
          });
        }
      }
    });
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
              setState(() {
                leftAlready = true;
              });
              Navigator.of(context).pop();
            } else {
              if (!leftAlready) {
                setState(() {
                  _loading = true;
                  _searched = !_searched;
                });
                users = await getUsers(_searchController.text);
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
          title: Text(users[index]),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  YourPublicProfile(false, friendUserName: users[index]))),
        );
      },
    );
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
}
