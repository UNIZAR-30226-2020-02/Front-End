import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:async/async.dart';
import 'package:path/path.dart';
import 'dart:convert';

var defaultImagePath =
    'https://i7.pngguru.com/preview/753/432/885/user-profile-2018-in-sight-user-conference-expo-business-default-business.jpg';
var imagePath;

Future uploadImage(SharedPreferences sharedPreferences) async {
  sharedPreferences = await SharedPreferences.getInstance();

  var image = await ImagePicker.pickImage(source: ImageSource.gallery);
  if (image != null) {
    // Abre un stream de bytes
    var stream = http.ByteStream(DelegatingStream.typed(image.openRead()));
    //Longitud de la imagen
    var length = await image.length();
    // Uri del servidor
    var uri = Uri.parse("https://playstack.azurewebsites.net/");
    // Crear peticion multiparte
    var request = new http.MultipartRequest("POST", uri);
    // multipart that takes file
    var multipartFile = new http.MultipartFile('NuevaFoto', stream, length,
        filename: basename(image.path));
    // add file to multipart
    request.files.add(multipartFile);
    // send
    var response = await request.send();
    print("Status code devuelto " + response.statusCode.toString());

    // listen for response
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });

    /*
      setState(() {
        imagePath = ...
      });
      */
  }
}

class ProfilePicture extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
//backgroundColor: Color(0xFF191414),
        radius: 60,
        backgroundImage: (imagePath != null)
            ? NetworkImage(imagePath)
            : NetworkImage(defaultImagePath));
  }
}

// Check if its a digit
bool isDigit(String s) => "0".compareTo(s[0]) <= 0 && "9".compareTo(s[0]) >= 0;

// Checks if the password is secure enough
bool passwordIsSafe(String password) {
  bool isSafe = false;
  var char = '';

  if (password.length >= 8) {
    for (int i = 0; i < password.length; i++) {
      char = password.substring(i, i + 1);
      if (!isDigit(char)) {
        if (char == char.toUpperCase()) {
          isSafe = true;
        }
      }
    }
  }
  return isSafe;
}

class SongItem extends StatelessWidget {
  final title;
  final artist;
  final image;
  SongItem(this.title, this.artist, this.image);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('Se reproducirá la canción');
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 26.0),
        child: Row(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  height: 80.0,
                  width: 80.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                    height: 80.0,
                    width: 80.0,
                    child: Icon(
                      Icons.play_circle_filled,
                      color: Colors.white.withOpacity(0.7),
                      size: 42.0,
                    ))
              ],
            ),
            SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0),
                ),
                SizedBox(height: 8.0),
                Text(
                  artist,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 18.0),
                ),
              ],
            ),
            Spacer(),
            Icon(
              Icons.more_horiz,
              color: Colors.white.withOpacity(0.6),
              size: 32.0,
            )
          ],
        ),
      ),
    );
  }
}
