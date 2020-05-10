import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:playstack/models/FolderType.dart';
import 'package:playstack/models/PlaylistType.dart';
import 'package:playstack/models/Song.dart';
import 'package:playstack/models/user.dart';
import 'package:playstack/shared/common.dart';

Future<List> getpublicPlaylistsDB(bool mine, {String user}) async {
  List publicPlaylists = new List();

  dynamic response;
  if (mine) {
    print("Recuperando playlists publicas mias $userName");
    response = await http.get(
        'https://playstack.azurewebsites.net/get/publicplaylists?NombreUsuario=$userName');
  } else {
    print("Recuperando playlists publicas de  $user");
    response = await http.get(
        'https://playstack.azurewebsites.net/get/publicplaylists?NombreUsuario=$user');
  }

  if (response.statusCode == 200) {
    response = jsonDecode(response.body);
    print("Playlists publicas recuperadas");
    //FotoDePerfil
    response.forEach((name, info) => addPlaylistToList(
        publicPlaylists, name, info['Fotos'], info['Privado']));
  } else {
    print('Error playlists publicas');
  }
  print("Tiene " + following.length.toString() + " playlists publicas");
  return publicPlaylists;
}

Future<List> getUsersFollowingDB() async {
  print("Recuperando usuarios seguidos de $userName");

  List following = new List();
  dynamic response = await http.get(
      'https://playstack.azurewebsites.net/user/get/following?Usuario=$userName');

  if (response.statusCode == 200) {
    response = jsonDecode(response.body);
    print("Usuarios seguidos recuperados");
    //FotoDePerfil
    response.forEach((title, profilePhoto) => addUserToList(
          following,
          title,
          profilePhoto['FotoDePerfil'],
        ));
  } else {
    print('Error buscando followers');
  }
  print("Tiene " + following.length.toString() + " following");
  return following;
}

Future<bool> removeSongFromPlaylistDB(
    String songName, String playlistName) async {
  print("Quitando cancion $songName de playlist $playlistName");
  dynamic data = {
    'NombreUsuario': userName,
    'NombrePlayList': playlistName,
    'NombreCancion': songName,
  };

  data = jsonEncode(data);
  dynamic response = await http.post(
      "https://playstack.azurewebsites.net/user/remove/song/fromplaylist",
      headers: {"Content-Type": "application/json"},
      body: data);

  print("Statuscode quitar cancion de playlist: " +
      response.statusCode.toString());

  if (response.statusCode == 200) {
    print("Cancion quitada");
    return true;
  } else {
    print("Cancion no quitada: " + response.body.toString());
    return false;
  }
}

Future<bool> addSongToPlaylistDB(String playlistName, String songName) async {
  print("Añadiendo cancion $songName a playlist $playlistName");
  dynamic data = {
    'NombreUsuario': userName,
    'NombrePlayList': playlistName,
    'NombreCancion': songName,
  };

  data = jsonEncode(data);
  dynamic response = await http.post(
      "https://playstack.azurewebsites.net/user/add/song/toplaylist",
      headers: {"Content-Type": "application/json"},
      body: data);

  print("Statuscode agnadir cancion a playlist: " +
      response.statusCode.toString());

  if (response.statusCode == 200) {
    print("Cancion agnadida");
    return true;
  } else {
    print("Cancion no agnadida: " + response.body.toString());
    return false;
  }
}

Future<bool> updatePlaylistDB(
    String playlistName, String newPLaylistName, bool isPrivate) async {
  print(
      "Actualizando playlist $playlistName a $newPLaylistName es privada $isPrivate");
  dynamic data = {
    'NombreUsuario': userName,
    'NombrePlayList': playlistName,
    'NuevoNombre': newPLaylistName,
    'NuevoPrivado': isPrivate
  };

  data = jsonEncode(data);
  dynamic response = await http.post(
      "https://playstack.azurewebsites.net/user/update/playlist",
      headers: {"Content-Type": "application/json"},
      body: data);

  print("Statuscode actualizar playlist: " + response.statusCode.toString());

  if (response.statusCode == 200) {
    print("playlist actualizada");
    return true;
  } else {
    print("Playlist no actualizada " + response.body.toString());
    return false;
  }
}

Future<bool> deleteFolderDB(String folderName) async {
  print("Borrando carpeta $folderName");
  dynamic data = {'NombreUsuario': userName, 'NombreCarpeta': folderName};

  data = jsonEncode(data);
  dynamic response = await http.post(
      "https://playstack.azurewebsites.net/user/remove/folder/",
      headers: {"Content-Type": "application/json"},
      body: data);

  print("Statuscode borrar carpeta: " + response.statusCode.toString());

  if (response.statusCode == 200) {
    print("Carpeta borrada");
    return true;
  } else {
    print("Carpeta no ha sido borrada: " + response.body.toString());
    return false;
  }
}

Future<bool> deletePlaylistDB(String playlistName) async {
  print("Borrando playlist $playlistName");
  dynamic data = {'NombreUsuario': userName, 'NombrePlayList': playlistName};

  data = jsonEncode(data);
  dynamic response = await http.post(
      "https://playstack.azurewebsites.net/user/remove/playlist/",
      headers: {"Content-Type": "application/json"},
      body: data);

  print("Statuscode borrar playlist: " + response.statusCode.toString());

  if (response.statusCode == 200) {
    print("Playlist borrada");
    return true;
  } else {
    print("Playlist no ha sido borrada: " + response.body.toString());
    return false;
  }
}

Future<List> updatePlaylistCoversDB(String playlistName) async {
  List coverUrls = new List();

  print("Recuperando covers de $playlistName");
  dynamic response = await http.get(
      "https://playstack.azurewebsites.net/get/playlist/songs?NombreUsuario=$userName&NombrePlayList=$playlistName");

  if (response.statusCode == 200) {
    response = json.decode(response.body);

    response.forEach((title, info) => print(title + info.toString()));
    response.forEach(
        (title, info) => coverUrls.add(info['ImagenesAlbums'].elementAt(0)));

    //title, info['Artistas'],info['url'], info['Albunes'], info['ImagenesAlbum']
  } else {
    print("Status code not 200, body: " + response.body);
  }
  print("Hay " + coverUrls.length.toString() + " covers en $playlistName");
  return coverUrls;
}

Future<List> getPlaylistSongsDB(String playlistName) async {
  List playlistSongs = new List();

  print("Recuperando canciones de $playlistName");
  dynamic response = await http.get(
      "https://playstack.azurewebsites.net/get/playlist/songs?NombreUsuario=$userName&NombrePlayList=$playlistName");

  print("Statuscode recoger canciones de playlist $playlistName: " +
      response.statusCode.toString());

  if (response.statusCode == 200) {
    response = json.decode(response.body);

    response.forEach((title, info) => print(title + info.toString()));
    response.forEach((title, info) => addSongToList(
        playlistSongs,
        title,
        info['Artistas'],
        info['Albumes'],
        info['ImagenesAlbums'],
        info['url']));

    //title, info['Artistas'],info['url'], info['Albunes'], info['ImagenesAlbum']
  } else {
    print("Status code not 200, body: " + response.body);
  }
  print(
      "Hay " + playlistSongs.length.toString() + " canciones en $playlistName");
  return playlistSongs;
}

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

Future<bool> createFolderDB(String folderName, String playlistName) async {
  print("Creando carpeta $folderName con playlist $playlistName");
  dynamic data = {
    'NombreUsuario': userName,
    'NombreCarpeta': folderName,
    'NombrePlayList': playlistName
  };

  data = jsonEncode(data);
  dynamic response = await http.post(
      "https://playstack.azurewebsites.net/create/folder",
      headers: {"Content-Type": "application/json"},
      body: data);

  print("Statuscode crearcarpeta: " + response.statusCode.toString());

  if (response.statusCode == 200) {
    print("Carpeta creada");
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

addUserToList(List list, String name, String photoUrl) {
  User newUser = new User(name, photoUrl);
  list.add(newUser);
}

Future<List> getFollowersDB() async {
  print("Recuperando followers de $userName");

  List followers = new List();
  dynamic response = await http.get(
      'https://playstack.azurewebsites.net/user/get/followers?Usuario=$userName');

  if (response.statusCode == 200) {
    response = jsonDecode(response.body);
    print("Followers recuperados");
    //FotoDePerfil
    response.forEach((title, profilePhoto) => addUserToList(
          followers,
          title,
          profilePhoto['FotoDePerfil'],
        ));
  } else {
    print('Error buscando followers');
  }
  print("Tiene " + followers.length.toString() + " followers");
  return followers;
}

Future<bool> follow(String newFriend) async {
  print("Siguiendo $userName a $newFriend...");
  dynamic data = {'Usuario': userName, 'Seguidor': newFriend};

  data = jsonEncode(data);
  dynamic response = await http.post(
      "https://playstack.azurewebsites.net/user/follow",
      headers: {"Content-Type": "application/json"},
      body: data);

  print("Statuscode follow: " + response.statusCode.toString());

  if (response.statusCode == 200) {
    print("Usuario seguido");
    return true;
  } else {
    print("Usuario no seguido, body: " + response.body.toString());
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
  List tempList = new List();
  dynamic response = await http.get(
      'https://playstack.azurewebsites.net/user/get/followers?Usuario=$otherPerson');

  print("Codigo recuperando followers de amigo: " +
      response.statusCode.toString());
  print("Response " + response.body.toString());

  if (response.statusCode == 200) {
    response = jsonDecode(response.body);
    //Tiene algun follower
    response.forEach((title, profilePhoto) => tempList.add(title));

    if (tempList.length > 0) {
      for (var user in tempList) {
        if (user == userName) return true;
      }
    }
    return false;
  } else {
    print('Error buscando usuarios');

    return true;
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
  dynamic isPriv = isPrivate;
  isPriv = isPriv.toString();
  print("Creando playlist " +
      playlistname +
      " del usuario " +
      userName +
      " es privada " +
      isPrivate.toString());

  dynamic data = {
    'NombreUsuario': userName,
    'NombrePlayList': playlistname,
    'EsPrivado': isPrivate
  };

  data = jsonEncode(data);
  print("La data es $data");
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
    if (covers == '') {
      covers = new List();
    } else {
      covers = covers.toList();
    }
  }
  PlaylistType newPlaylist =
      PlaylistType(name: name, coverUrls: covers, isPrivate: isPrivate);
  playlists.add(newPlaylist);
}

addFolderToList(List folders, String folderName, List containedPlaylists) {
  FolderType newFolder =
      new FolderType(name: folderName, containedPlaylists: containedPlaylists);
  folders.add(newFolder);
}

Future<List> getUserFolders() async {
  List folders = new List();

  print("Recuperando carpetas de " + userName);
  dynamic response = await http.get(
      "https://playstack.azurewebsites.net/get/folders?NombreUsuario=$userName");

  print("Statuscode carpetas: " + response.statusCode.toString());

  if (response.statusCode == 200) {
    response = json.decode(response.body);
    response.forEach(
        (name, playlistNames) => addFolderToList(folders, name, playlistNames));
  } else {
    print("Status code not 200, body: " + response.body);
  }
  print("Hay " + folders.length.toString() + " carpetas de $userName");
  return folders;
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
      "https://playstack.azurewebsites.net/user/get/favoritesongs?NombreUsuario=$userName");

  print("Statuscode favoritas: " + response.statusCode.toString());

  if (response.statusCode == 200) {
    print("Favoritas recuperadas");
    response = json.decode(response.body);

    //response.forEach((title, info) => print(title + info.toString()));
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
  print("Hay " + favSongs.length.toString() + " favoritas");
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
Future uploadImage(var image) async {
  print("Subiendo foto de " + userName);
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
