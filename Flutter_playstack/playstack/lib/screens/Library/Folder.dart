import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:playstack/models/FolderType.dart';
import 'package:playstack/shared/common.dart';

class Folder extends StatelessWidget {
  final FolderType folder;

  Folder(this.folder);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Color.fromRGBO(80, 20, 20, 4.0),
            Color(0xFF191414),
          ], begin: Alignment.topLeft, end: FractionalOffset(0.3, 0.3)),
        ),
        child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.of(context).pop()),
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              centerTitle: true,
              title: Text(folder.name),
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10.0),
              ),
            ),
            backgroundColor: Colors.transparent,
            body: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: folder.containedPlaylists.length == 0
                  ? 0
                  : folder.containedPlaylists.length,
              itemBuilder: (BuildContext context, int index) {
                return new PlaylistItem(
                    folder.containedPlaylists[index], false);
              },
            )));
  }
}
