import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // final formKey = new GlobalKey<FormState>();
  // final key = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return defSearchScreen();
  }

  Widget defSearchScreen() {
    return Scaffold(
      backgroundColor: Color(0xFF191414),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 20, 15, 0),
        child: ListView(
          children: <Widget>[
            Text(
              'Search',
              style: TextStyle(fontFamily: 'Circular', fontSize: 25),
            ),
            _searchBar(context),
          ],
        ),
      ),
    );
  }

  Widget _searchBar(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
            child: FlatButton(
                color: Colors.white,
                onPressed: () =>
                    Navigator.of(context).pushNamed('searchProcessScreen'),
                child: SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.search,
                        color: Colors.black,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Artists, songs or Podcasts',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      ),
                    ],
                  ),
                )))
      ],
    );
  }
}
