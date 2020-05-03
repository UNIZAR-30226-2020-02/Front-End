import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playstack/screens/Homescreen/PublicProfile.dart';
import 'package:playstack/services/database.dart';

class SearchPeople extends StatefulWidget {
  @override
  _SearchPeopleState createState() => _SearchPeopleState();
}

class _SearchPeopleState extends State<SearchPeople> {
  final TextEditingController _searchController = new TextEditingController();

  String _searchText = "";

  bool _searched = false;

  List users = new List();

  @override
  void initState() {
    super.initState();
    getAllUsers();
  }

  void getAllUsers() async {
    users = await getUsers("");
    print("Recopilados todos los usuarios");
    setState(() {});
  }

  _SearchPeopleState() {
    _searchController.addListener(() {
      if (_searchController.text.isEmpty) {
        setState(() {
          _searched = false;
          _searchText = "";
        });
      } else {
        setState(() {
          _searchText = _searchController.text;
        });
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
                      hintStyle: TextStyle(color: Colors.black))),
            ),
          ],
        )),
        IconButton(
          icon: _searched ? Icon(Icons.cancel) : Icon(Icons.search),
          onPressed: () async {
            if (_searched) {
              Navigator.of(context).pop();
            } else {
              users = await getUsers(_searchController.text);
              setState(() {
                _searched = !_searched;
              });
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
            _buildList(),
          ],
        ),
      ),
      resizeToAvoidBottomPadding: false,
    );
  }
}
