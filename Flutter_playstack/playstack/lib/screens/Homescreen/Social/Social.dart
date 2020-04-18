import 'package:flutter/material.dart';

class Social extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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
                  'Siguiendo',
                  style: TextStyle(fontFamily: 'Circular', fontSize: 20),
                ),
              ),
              Tab(
                child: Text(
                  'Seguidores',
                  style: TextStyle(fontFamily: 'Circular', fontSize: 20),
                ),
              ),
              Tab(
                child: Text(
                  'Solicitudes',
                  style: TextStyle(fontFamily: 'Circular', fontSize: 20),
                ),
              ),
            ],
          ),
          title: Text(
            "Social",
            style: TextStyle(fontFamily: 'Circular'),
          ),
        ),
        body: TabBarView(
          children: [Center(child: Text('tab1')), Text('tab2'), Text('Tab3')],
        ),
      ),
    );
  }
}
