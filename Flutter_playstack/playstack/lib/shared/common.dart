import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:async/async.dart';
import 'package:path/path.dart';
import 'dart:convert';

var defaultImagePath = 'https://i7.pngguru.com/preview/753/432/885/user-profile-2018-in-sight-user-conference-expo-business-default-business.jpg';
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


class ProfilePicture extends StatelessWidget{
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

