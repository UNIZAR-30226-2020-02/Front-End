import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:playstack/models/PlaylistType.dart';
import 'package:playstack/models/Song.dart';
import 'package:playstack/screens/Library/Playlist.dart';
import 'package:playstack/shared/common.dart';

Future<List> getPublicPlaylists(String user) async {
  List allSongs = new List();
  dynamic response = await http.get(
      'https://playstack.azurewebsites.net/get/publicplaylists?NombreUsuario=$user');

  print("Codigo recuperando playlists de $user: " +
      response.statusCode.toString());
  if (response.statusCode == 200) {
    response = jsonDecode(response.body);
    print("REspuesta:" + response.toString());
  } else {
    print('Error buscando usuarios');
  }
  return allSongs;
}

Future<bool> createFolderDB(String folderName) async {
  dynamic data = {'Usuario': userName, 'Carpeta': folderName};

  data = jsonEncode(data);
  dynamic response = await http.post(
      "https://playstack.azurewebsites.net/create/folder",
      headers: {"Content-Type": "application/json"},
      body: data);

  print("Statuscode follow: " + response.statusCode.toString());

  if (response.statusCode == 200) {
    print("Marcada como escuchada");
    return true;
  } else {
    print("Status code not 200, body: " + response.body.toString());
    return false;
  }
}

Future<List> getAllSongs() async {
  List allSongs = new List();
  dynamic response =
      await http.get('https://playstack.azurewebsites.net/get/allsongs');

  print("Codigo recuperando canciones: " + response.statusCode.toString());
  if (response.statusCode == 200) {
    response = jsonDecode(response.body);
    print("REspuesta:");
    response.forEach((title, info) => print(title + info.toString()));
    response.forEach((title, info) => addSongToList(
        allSongs,
        title,
        info['Artistas'],
        info['Albumes'],
        info['ImagenesAlbums'],
        info['url']));
  } else {
    print('Error buscando usuarios');
  }
  return allSongs;
}

Future<List> getFollowersDB() async {
  dynamic response = await http.get(
      'https://playstack.azurewebsites.net/user/get/profilephoto?Usuario=$userName');

  print("Codigo recuperando followers: " + response.statusCode.toString());
  if (response.statusCode == 200) {
    response = jsonDecode(response.body);
    print("Response " + response.toString());
    return response['Usuarios'];
  } else {
    print('Error buscando usuarios');

    return null;
  }
}

Future<bool> follow(String newFriend) async {
  dynamic data = {'Usuario': userName, 'Seguidor': newFriend};

  data = jsonEncode(data);
  dynamic response = await http.post(
      "https://playstack.azurewebsites.net/user/follow",
      headers: {"Content-Type": "application/json"},
      body: data);

  print("Statuscode follow: " + response.statusCode.toString());

  if (response.statusCode == 200) {
    print("Marcada como escuchada");
    return true;
  } else {
    print("Status code not 200, body: " + response.body.toString());
    return false;
  }
}

Future<String> getForeignPicture(String username) async {
  dynamic response = await http.get(
      'https://playstack.azurewebsites.net/user/get/profilephoto?Usuario=$username');

  print("Codigo recuperando foto de amigo: " + response.statusCode.toString());
  if (response.statusCode == 200) {
    response = jsonDecode(response.body);
    print("Response " + response.toString());
    return response['FotoDePerfil'];
  } else {
    print('Error cogiendo foto de perfil ');

    return null;
  }
}

Future<bool> checkIfFollowing(String otherPerson) async {
  dynamic response = await http.get(
      'https://playstack.azurewebsites.net/user/get/followers?Usuario=$otherPerson');

  print("Codigo recuperando followers de amigo: " +
      response.statusCode.toString());
  print("Response " + response.body.toString());

  if (response.statusCode == 200) {
    response = jsonDecode(response.body);
    //Tiene algun follower
    if (response.length > 0) {
      for (var user in response['Usuarios']) {
        if (user == userName) return true;
      }
    }
    return false;
  } else {
    print('Error buscando usuarios');

    return null;
  }
}

Future<List> getUsers(String keyword) async {
  print("Searching for " + keyword);
  dynamic response = await http
      .get('https://playstack.azurewebsites.net/user/search?KeyWord=$keyword');
  if (response.statusCode == 200) {
    response = jsonDecode(response.body);
    print("Response " + response.toString());
    return response['Usuarios'];
  } else {
    print('Error buscando usuarios');

    return null;
  }
}

void setLastSongAsCurrent() async {
  dynamic response = await http.get(
      "https://playstack.azurewebsites.net/user/get/lastsong?Usuario=$userName");

  print("Statuscode " + response.statusCode.toString());
  //print("Body:" + response.body.toString());
  if (response.statusCode == 200) {
    response = jsonDecode(response.body);
    response.forEach((title, info) => print(title + info.toString()));
    currentSong = new Song();
    response.forEach((title, info) => currentSong.setInfo(
        title,
        info['Artistas'],
        info['url'],
        info['Albumes'],
        info['ImagenesAlbums'],
        info['Generos']));
    print("Ultima cancion seteada");
  } else {
    print('Error cogiendo ultima cancion escuchada');
  }
}

Future<bool> createPlaylistDB(String playlistname, bool isPrivate) async {
  print("Creando playlist " +
      playlistname +
      " del usuario " +
      userName +
      " es privada " +
      isPrivate.toString());

  dynamic data = {
    'NombreUsuario': userName,
    'NombrePlayList': playlistname,
    'EsPrivado': isPrivate.toString()
  };

  data = jsonEncode(data);
  dynamic response = await http.post(
      "https://playstack.azurewebsites.net/create/playlist",
      headers: {"Content-Type": "application/json"},
      body: data);

  print("Statuscode crear playlist: " + response.statusCode.toString());

  if (response.statusCode == 200) {
    print("Playlist " + playlistname + " creada");
    return true;
  } else {
    print("Status code not 200, body: " + response.body.toString());
    return false;
  }
}

addPlaylistToList(List playlists, String name, dynamic covers, bool isPrivate) {
  if (covers == null) {
    covers = new List();
  } else if (covers is String) {
    covers = covers.toList();
  }
  PlaylistType newPlaylist =
      PlaylistType(name: name, coverUrls: covers, isPrivate: isPrivate);
  playlists.add(newPlaylist);
}

Future<List> getUserPlaylists() async {
  List playlists = new List();

  print("Recuperando playlists de " + userName);
  dynamic response = await http.get(
      "https://playstack.azurewebsites.net/user/get/playlists?NombreUsuario=$userName");

  print("Statuscode playlists: " + response.statusCode.toString());

  if (response.statusCode == 200) {
    response = json.decode(response.body);
    response.forEach((name, covers) => print(name + covers.toString()));
    response.forEach((name, info) =>
        addPlaylistToList(playlists, name, info['Fotos'], info['Privado']));
  } else {
    print("Status code not 200, body: " + response.body);
  }

  return playlists;
}

addSongToList(List songs, String title, List artists, List albums,
    List albumCoverUrls, String url) {
  Song newSong = new Song(
      title: title,
      artists: artists,
      url: url,
      albums: albums,
      albumCoverUrls: albumCoverUrls);
  songs.add(newSong);
}

Future<List> getFavoriteSongs() async {
  List favSongs = new List();

  print("Recuperando favoritas de " + userName);
  dynamic response = await http.get(
      "https://playstack.azurewebsites.net/user/get/favoritesongs?Usuario=$userName");

  print("Statuscode favoritas: " + response.statusCode.toString());

  if (response.statusCode == 200) {
    response = json.decode(response.body);

    response.forEach((title, info) => print(title + info.toString()));
    response.forEach((title, info) => addSongToList(
        favSongs,
        title,
        info['Artistas'],
        info['Albumes'],
        info['ImagenesAlbums'],
        info['url']));

    //title, info['Artistas'],info['url'], info['Albunes'], info['ImagenesAlbum']
  } else {
    print("Status code not 200, body: " + response.body);
  }

  return favSongs;
}

void markAsListenedDB(String songTitle) async {
  print(
      "Probando con nombre de usuario " + userName + " y titulo " + songTitle);
  dynamic data = {'Usuario': userName, 'Titulo': songTitle};

  data = jsonEncode(data);
  dynamic response = await http.post(
      "https://playstack.azurewebsites.net/user/add/song/tolistened",
      headers: {"Content-Type": "application/json"},
      body: data);

  print("Statuscode marcar como escuchada: " + response.statusCode.toString());

  if (response.statusCode == 200) {
    print("Marcada como escuchada");
  } else {
    print("Status code not 200, body: " + response.body.toString());
  }
}

Future<bool> toggleFav(String songTitle, bool add) async {
  print("Cambiando estado de fav con " + userName + " y cancion " + songTitle);
  dynamic data = {'Usuario': userName, 'Titulo': songTitle};

  data = jsonEncode(data);

  dynamic response;
  if (add) {
    response = await http.post(
        "https://playstack.azurewebsites.net/user/add/song/tofavorites",
        headers: {"Content-Type": "application/json"},
        body: data);
    print("Statuscode agnadir a favoritos: " + response.statusCode.toString());
  } else {
    print("La intenta quitar de favs...");
    response = await http.post(
        "https://playstack.azurewebsites.net/user/remove/song/fromfavorites",
        headers: {"Content-Type": "application/json"},
        body: data);
    print("Statuscode quitar de favoritos: " + response.statusCode.toString());
  }

  if (response.statusCode == 200) {
    print("Agnadida/quitada a favoritos");
    return true;
  } else {
    //print("Status code not 200, body: " + response.body.toString());
    return false;
  }
}

Future updateUsername(String newUserName) async {
  print("Actualizando foto de  " + userName + " a " + newUserName);

  dynamic data = {
    'NombreUsuarioActual': userName,
    'NuevoNombreUsuario': newUserName
  };
  data = jsonEncode(data);
  dynamic response = await http.post(
      "https://playstack.azurewebsites.net/user/update/fields",
      headers: {"Content-Type": "application/json"},
      body: data);

  print("Statuscode act nombre usuario: " + response.statusCode.toString());

  if (response.statusCode == 200) {
    userName = newUserName;
    print("Nombre actualizado");
  } else {
    print("Status code not 200, body: " + response.body.toString());
    return null;
  }
}

// Para subir fotos
Future uploadImage() async {
  print("Subiendo foto de " + userName);
  var image = await ImagePicker.pickImage(source: ImageSource.gallery);
  FormData formData = new FormData.fromMap({
    "NombreUsuario": userName,
    "NuevaFoto": await MultipartFile.fromFile(image.path)
  });
  var response = await dio.post(
      "https://playstack.azurewebsites.net/user/update/image",
      data: formData, onSendProgress: (received, total) {
    if (total != -1) {
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  });
  imagePath = null;
}

Future<String> _getSongUrl(String songName) async {
  print("Intento conger url");

  var jsonResponse = null;
  var response = await http
      .get("https://playstack.azurewebsites.net/GetSong?Titulo=$songName");
  /*var response = await http.get(
      Uri.encodeFull("https://jsonplaceholder.typicode.com/posts"),
    );*/
  if (response.statusCode == 200) {
    jsonResponse = json.decode(response.body);
    if (jsonResponse != null) {
      print("Json response: " + jsonResponse.toString());
      print("Url: " + jsonResponse[0]["URL"].toString());
      return jsonResponse[0]["URL"];
    }
  } else {
    print("Status code not 200, body: " + response.body);
    return null;
  }
  print("Statuscode: " + response.statusCode.toString());
}

Future getProfilePhoto() async {
  print("Recuperando foto de " + userName);
  dynamic response = await http.get(
      "https://playstack.azurewebsites.net/user/get/profilephoto?Usuario=$userName");

  print("Statuscode foto: " + response.statusCode.toString());

  if (response.statusCode == 200) {
    response = json.decode(response.body);
    print("Response: " + response.toString());
    imagePath = response['FotoDePerfil'];
  } else {
    print("Status code not 200, body: " + response.body);
    return null;
  }
}
