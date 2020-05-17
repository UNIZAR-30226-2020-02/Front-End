import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class LocalMusic extends StatefulWidget {
  @override
  _LocalMusicState createState() => _LocalMusicState();
}

class _LocalMusicState extends State<LocalMusic> {
  bool _loading = true;
  String _path;

  void _openFileExplorer() async {
    try {
      _path = await FilePicker.getFilePath(
        type: FileType.audio,
      );
      print("El path es $_path");
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Música del dispositivo"),
      ),
      body: Center(
        child: RaisedButton(onPressed: _openFileExplorer),
      ),
    );
  }
}
