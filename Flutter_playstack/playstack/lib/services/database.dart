import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:playstack/models/Album.dart';
import 'package:playstack/models/Artist.dart';
import 'package:playstack/models/Episode.dart';
import 'package:playstack/models/FolderType.dart';
import 'package:playstack/models/Genre.dart';
import 'package:playstack/models/PlaylistType.dart';
import 'package:playstack/models/Podcast.dart';
import 'package:playstack/models/Song.dart';
import 'package:playstack/models/user.dart';
import 'package:playstack/screens/Library/Language.dart';
import 'package:playstack/shared/common.dart';

void addSongToListFull(List songs, String title, List artists, String url,
    dynamic albunes, dynamic urlAlbums, bool isFavorite) {
  if (urlAlbums is String) {
    urlAlbums = urlAlbums.toList();
  }

  Song newSong = new Song(
      title: title,
      artists: artists,
      url: url,
      albums: albunes,
      albumCoverUrls: urlAlbums,
      isFav: isFavorite);

  songs.add(newSong);
}

void addPodcastToList(
  List podcasts,
  String title,
  String coverUrl,
) {
  Podcast newPodcast = new Podcast(title: title, coverUrl: coverUrl);

  podcasts.add(newPodcast);
}

Future<void> getMostListenedTo(String user) async {
  print("Recopilando canciones mas escuchadas de $user");
  dynamic response = await http.get(
    "https://playstack.azurewebsites.net/user/get/mostListenedSongs?Usuario=$user",
    headers: {"Content-Type": "application/json"},
  );
  //print("Body:" + response.body.toString());
  if (response.statusCode == 200) {
    songsMostListenedTo.clear();
    podcastsmostListenedTo.clear();
    response = jsonDecode(response.body);
    //response.forEach((title, info) => print(title + info.toString()));
    response.forEach((title, info) {
      if (info['Tipo'] == "Cancion") {
        addSongToListFull(
            songsMostListenedTo,
            title,
            info['Artistas'],
            info['url'],
            info['Albumes'],
            info['ImagenesAlbums'],
            info['EsFavorita']);
      } else {
        addPodcastToList(podcastsmostListenedTo, title, info['Imagen']);
      }
    });

    print("Ha escuchado ${songsMostListenedTo.length.toString()} canciones");
    print("Ha escuchado ${podcastsmostListenedTo.length.toString()} podcasts");

    //print("Hay ${songs.length.toString()} canciones del genero $genre");
  } else {
    print("Statuscode " + response.statusCode.toString());

    print(response.body.toString());
  }
}

Future<List<Song>> getSongsByGenre(String genre) async {
  List<Song> songs = new List();
  print("Recopilando genero $genre...");
  dynamic response = await http.get(
    "https://playstack.azurewebsites.net/get/song/bygenre?NombreGenero=$genre&Usuario=$userName",
    headers: {"Content-Type": "application/json"},
  );
  //print("Body:" + response.body.toString());
  if (response.statusCode == 200) {
    response = jsonDecode(response.body);
    //response.forEach((title, info) => print(title + info.toString()));
    response.forEach((title, info) => addSongToListFull(
        songs,
        title,
        info['Artistas'],
        info['url'],
        info['Albumes'],
        info['ImagenesAlbum'],
        info['EsFavorita']));
    print("Hay ${songs.length.toString()} canciones del genero $genre");
  } else {
    print("Statuscode " + response.statusCode.toString());

    print(response.body.toString());
  }
  return songs;
}

addGenreToList(List genres, String name, String photoUrl) {
  Genre genre = new Genre(name, photoUrl);
  genres.add(genre);
}

Future<List<Genre>> getAllGenres({@required bool onlyFirtstFour}) async {
  print("Recuperando todos los generos");

  List<Genre> genres = new List();
  dynamic response =
      await http.get('https://playstack.azurewebsites.net/get/allgenders');

  if (response.statusCode == 200) {
    response = jsonDecode(response.body);
    print("Generos recuperados");

    response
        .forEach((name, coverUrl) => addGenreToList(genres, name, coverUrl));
  } else {
    print("Statuscode de recuperar generos " + response.statusCode.toString());
    print('Error buscando generos, body: ' + response.body.toString());
  }
  print("Hay " + genres.length.toString() + " generos");
  if (onlyFirtstFour) {
    List<Genre> firstFourGenres = new List();
    for (var i = 0; i < 4 && i < genres.length; i++) {
      firstFourGenres.add(genres.elementAt(i));
    }
    return firstFourGenres;
  } else
    return genres;
}

Future<List<Genre>> getFavouriteGenres(String user) async {
  print("Recuperando generos mas escuchados");

  List<Genre> genres = new List();
  dynamic response = await http.get(
      'https://playstack.azurewebsites.net/user/get/mostListenedGenres?NombreUsuario=$user');

  if (response.statusCode == 200) {
    response = jsonDecode(response.body);
    print("Generos mas escuchados recuperados");

    response
        .forEach((name, coverUrl) => addGenreToList(genres, name, coverUrl));
  } else {
    print("Statuscode de recuperar generos " + response.statusCode.toString());
    print('Error buscando generos, body: ' + response.body.toString());
  }
  print("Hay " + genres.length.toString() + " generos");

  return genres;
}

Future<List> search(String keyword) async {
  List allLists = new List();
  List<Song> songs = new List();
  List<PlaylistType> playlists = new List();
  List<Album> albums = new List();
  List<Podcast> podcasts = new List();
  List<Artist> artists = new List();

  allLists.add(songs);
  allLists.add(playlists);
  allLists.add(albums);
  allLists.add(podcasts);
  allLists.add(artists);

  print("Buscando palabra $keyword...");

  dynamic response = await http.get(
      'https://playstack.azurewebsites.net/search/?KeyWord=$keyword&NombreUsuario=$userName');

  if (response.statusCode == 200) {
    response = jsonDecode(response.body);
    print("REcuperado de todo con keyword $keyword");

    response
        .forEach((category, data) => addDataToList(allLists, category, data));
  } else {
    print("Statuscode de recuperar cosicas varias  " +
        response.statusCode.toString());
    print('Error recuperar cosicas varias, body: ' + response.body.toString());
  }
  return allLists;
}

void addDataToList(List list, String category, dynamic data) {
  switch (category) {
    case "Canciones":
      data.forEach((title, info) => addSongToListFull(
          list.elementAt(0),
          title,
          info['Artistas'],
          info['url'],
          info['Albumes'],
          info['ImagenesAlbum'],
          info['EsFavorita']));
      print("Hay ${list.elementAt(0).length.toString()} canciones");

      break;

    case "PlayLists":
      data.forEach((name, info) => addPlaylistToList(
          list.elementAt(1), name, info['Fotos'], info['Privado']));
      print("Hay ${list.elementAt(1).length.toString()} playlists");

      break;

    case "Albumes":
      data.forEach((name, coverUrl) => addAlbumToList(
            list.elementAt(2),
            name,
            coverUrl,
          ));
      print("Hay ${list.elementAt(2).length.toString()} albumes");

      break;

    case "Podcasts":
      data.forEach((title, coverUrl) =>
          addPodcastToList(list.elementAt(3), title, coverUrl));
      print("Hay ${list.elementAt(3).length.toString()} podcasts");

      break;
    default:
      // Artistas
      data.forEach((artista) => addArtistToList(
            list.elementAt(4),
            artista["Nombre"],
            artista["Foto"],
          ));

      print("Hay ${list.elementAt(4).length.toString()} artistas");
  }
}

Future<List> getAllPodcastsDB() async {
  print("Recuperando todos los podcasts");

  List podcasts = new List();
  dynamic response =
      await http.get('https://playstack.azurewebsites.net/get/allpodcasts');

  if (response.statusCode == 200) {
    response = jsonDecode(response.body);
    print("Podcasts recuperados");

    response.forEach(
        (title, coverUrl) => addPodcastToList(podcasts, title, coverUrl));
  } else {
    print("Statuscode de recuperar podcasts " + response.statusCode.toString());
    print('Error buscandopodcasts, body: ' + response.body.toString());
  }
  print("Hay " + podcasts.length.toString() + " podcasts");
  return podcasts;
}

Future<List> getAlbumSongs(String album) async {
  print("Recuperando camciones de album $album");

  List songs = new List();
  dynamic response = await http.get(
      'https://playstack.azurewebsites.net/get/song/byalbum?NombreUsuario=$userName&NombreAlbum=$album');

  if (response.statusCode == 200) {
    response = jsonDecode(response.body);
    print("Canciones de album $album recuperadas");

    response.forEach((title, info) => addSongToListFull(
        songs,
        title,
        info['Artistas'],
        info['url'],
        info['Albumes'],
        info['ImagenesAlbum'],
        info['EsFavorita']));
  } else {
    print("Statuscode de album $album " + response.statusCode.toString());
    print('Error buscando canciones de album $album, body: ' +
        response.body.toString());
  }
  print("El album tiene  " + songs.length.toString() + " canciones");
  return songs;
}

Future<List> getArtistAlbumsDB(String artistName) async {
  print("Recuperando albumes de $artistName");

  List albums = new List();
  dynamic response = await http.get(
      'https://playstack.azurewebsites.net/get/artist/albums?NombreArtista=$artistName');

  if (response.statusCode == 200) {
    response = jsonDecode(response.body);
    print("Albumes de $artistName recuperados");
    response.forEach((name, coverUrl) => addAlbumToList(
          albums,
          name,
          coverUrl,
        ));
  } else {
    print('Error buscando albumes');
  }
  print("Hay " + albums.length.toString() + " albumes");
  return albums;
}

addAlbumToList(List list, String name, String coverUrl) {
  Album newAlbum = new Album(name, coverUrl);
  list.add(newAlbum);
}

Future<List> getAlbumsDB() async {
  print("Recuperando albumes");

  List albums = new List();
  dynamic response =
      await http.get('https://playstack.azurewebsites.net/get/randomalbums');

  if (response.statusCode == 200) {
    response = jsonDecode(response.body);
    print("Albumes recuperados");
    response.forEach((name, coverUrl) => addAlbumToList(
          albums,
          name,
          coverUrl,
        ));
  } else {
    print('Error buscando albumes');
  }
  print("Hay " + albums.length.toString() + " albumes");
  return albums;
}

Future<bool> unfollow(String user) async {
  print("Dejando de seguir a $user");
  dynamic data = {'NombreUsuario': userName, 'Seguido': user};
  data = jsonEncode(data);
  dynamic response = await http.post(
      "https://playstack.azurewebsites.net/user/unfollow",
      headers: {"Content-Type": "application/json"},
      body: data);

  if (response.statusCode == 200) {
    print("Dejado de seguir a $user correctamente");
    return true;
  } else {
    print("Statuscode: " + response.statusCode.toString());
    print("No se pudo dejar de seguir a $user: " + response.body.toString());
    return false;
  }
}

Future<bool> rejectFollowRequest(String follower) async {
  print("Rechazando solicitud de $follower");
  dynamic data = {'NombreUsuario': userName, 'Seguidor': follower};
  data = jsonEncode(data);
  dynamic response = await http.post(
      "https://playstack.azurewebsites.net/user/reject/followRequest",
      headers: {"Content-Type": "application/json"},
      body: data);

  if (response.statusCode == 200) {
    print("Solicitud rechazada correctamente");
    return true;
  } else {
    print("No se pudo rechazar la solicitud de follow: " +
        response.body.toString());
    return false;
  }
}

Future<bool> removeFollowRequest(String follow) async {
  print("Retirando solicitud a $follow");
  dynamic data = {'NombreUsuario': userName, 'Seguido': follow};
  data = jsonEncode(data);
  dynamic response = await http.post(
      "https://playstack.azurewebsites.net/user/remove/followRequest",
      headers: {"Content-Type": "application/json"},
      body: data);

  if (response.statusCode == 200) {
    print("Solicitud eliminada correctamente");
    return true;
  } else {
    print("No se pudo eliminar la solicitud de follow: " +
        response.body.toString());
    return false;
  }
}

Future<bool> checkAccountType() async {
  print("Comprobando tipo de cuenta de $userName");
  dynamic response = await http.get(
      'https://playstack.azurewebsites.net/user/get/permissions?Usuario=$userName');

  if (response.statusCode == 200) {
    response = jsonDecode(response.body);
    print("Tipo de cuenta recuperada");
    accountType = response['Permiso'];
    return true;
  } else {
    print(
        'Error recuperando tipo de cuenta, body: ' + response.body.toString());
    return false;
  }
}

Future<bool> askToBecomePremium() async {
  print("Solicitando ser premium $userName");
  dynamic data = {
    'NombreUsuario': userName,
  };
  data = jsonEncode(data);
  dynamic response = await http.post(
      "https://playstack.azurewebsites.net/user/askforpremium",
      headers: {"Content-Type": "application/json"},
      body: data);

  if (response.statusCode == 200) {
    print("Solicitud enviada correctamente");
    return true;
  } else {
    print("No se pudo enviar la solicitud de hacerse premium: " +
        response.body.toString());
    return false;
  }
}

Future<bool> removePlaylistFromFolder(
    String playlistName, String folderName) async {
  print("Quitando playlist $playlistName de carpeta $folderName");
  dynamic data = {
    'NombreUsuario': userName,
    'NombreCarpeta': folderName,
    'NombrePlayList': playlistName,
  };

  data = jsonEncode(data);
  dynamic response = await http.post(
      "https://playstack.azurewebsites.net/user/remove/playlist/fromfolder",
      headers: {"Content-Type": "application/json"},
      body: data);

  if (response.statusCode == 200) {
    print("Playlist eliminada de carpeta");
    return true;
  } else {
    print("No se pudo eliminar la playlist a de la carpeta: " +
        response.body.toString());
    return false;
  }
}

Future<bool> addPlaylistToFolder(String playlistName, String folderName) async {
  print("Metiendo playlist $playlistName en carpeta $folderName");
  dynamic data = {
    'NombreUsuario': userName,
    'NombreCarpeta': folderName,
    'NombrePlayList': playlistName,
  };

  data = jsonEncode(data);
  dynamic response = await http.post(
      "https://playstack.azurewebsites.net/user/add/playlist/tofolder",
      headers: {"Content-Type": "application/json"},
      body: data);

  if (response.statusCode == 200) {
    print("Playlist metida en carpeta");
    return true;
  } else {
    print("No se pudo agnadir la playlist a la carpeta: " +
        response.body.toString());
    return false;
  }
}

addArtistToList(List artists, String name, String photoUrl) {
  Artist artist = new Artist(name, photoUrl);
  artists.add(artist);
}

Future<List> getAllArtistsDB() async {
  print("Recuperando todas los artistas");
  List artists = new List();
  dynamic response =
      await http.get('https://playstack.azurewebsites.net/get/allartists');

  if (response.statusCode == 200) {
    response = jsonDecode(response.body);
    print("Artistas recuperados");

    response.forEach((name, photo) => addArtistToList(artists, name, photo));
  } else {
    print('Error buscando artistas, body: ' + response.body.toString());
  }
  print("Hay" + artists.length.toString() + " artistas");
  return artists;
}

Future<void> getLastSongsListenedToDB(String user) async {
  print("Recuperando ultimas 20 canciones de $user");

  dynamic response = await http.get(
      'https://playstack.azurewebsites.net/user/get/lastsongs?Usuario=$user');

  if (response.statusCode == 200) {
    response = jsonDecode(response.body);
    recentlyPlayedPodcasts.clear();
    recentlyPlayedSongs.clear();
    /*  response
        .forEach((number, info) => print(title + " y info " + info.toString())); */
    //List songs, String title, List artists, List albums,List albumCoverUrls, String url
    response.forEach((number, info) {
      if (info['Tipo'] == "Cancion") {
        addSongToListFull(
            recentlyPlayedSongs,
            info['Titulo'],
            info['Artistas'],
            info['url'],
            info['Albumes'],
            info['ImagenesAlbums'],
            info['EsFavorita']);
      } else {
        addPodcastToList(
            recentlyPlayedPodcasts, info['Titulo'], info['Imagen']);
      }
    });
    print(
        "Recientemente ha escuchado ${recentlyPlayedSongs.length.toString()} canciones y${recentlyPlayedPodcasts.length.toString()} podcasts");
  } else {
    print(
        "Statuscode de ultimas 20 canciones " + response.statusCode.toString());
    print('Error buscando ultimas 20 canciones, body: ' +
        response.body.toString());
  }
}

Future<List> getArtistSongsDB(String artist) async {
  print("Recuperando canciones de artista $artist");

  List songs = new List();
  dynamic response = await http.get(
      'https://playstack.azurewebsites.net/get/song/byartist?NombreArtista=$artist&NombreUsuario=$userName');

  if (response.statusCode == 200) {
    response = jsonDecode(response.body);
    print("Canciones de $artist recuperadas");

    response.forEach((title, info) => addSongToListFull(
        songs,
        title,
        info['Artistas'],
        info['url'],
        info['Albumes'],
        info['ImagenesAlbum'],
        info["EsFavorita"]));
  } else {
    print(
        "Statuscode de canciones de artista " + response.statusCode.toString());
    print('Error buscando canciones de artista $artist, body: ' +
        response.body.toString());
  }
  print("Tiene " + songs.length.toString() + " canciones");
  return songs;
}

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

Future<List> getPlaylistSongsDB(String playlistName, {bool isNotOwn}) async {
  List playlistSongs = new List();
  dynamic response;
  if (isNotOwn == null) isNotOwn = false;
  if (isNotOwn) {
    print("Recuperando canciones de playlist $playlistName de $friendName");
    response = await http.get(
        "https://playstack.azurewebsites.net/get/playlist/songs?NombreUsuario=$friendName&NombrePlayList=$playlistName");
  } else {
    print("Recuperando canciones de playlist $playlistName de $userName");
    response = await http.get(
        "https://playstack.azurewebsites.net/get/playlist/songs?NombreUsuario=$userName&NombrePlayList=$playlistName");
  }

  print("Statuscode recoger canciones de playlist $playlistName: " +
      response.statusCode.toString());

  if (response.statusCode == 200) {
    response = json.decode(response.body);

    //response.forEach((title, info) => print(title + info.toString()));
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

/* 
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
 */
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
  print("Recuperando todas las canciones");
  List allSongs = new List();
  dynamic response = await http.get(
      'https://playstack.azurewebsites.net/get/allsongs?NombreUsuario=$userName');

  print("Codigo recuperando canciones: " + response.statusCode.toString());
  if (response.statusCode == 200) {
    response = jsonDecode(response.body);
    //response.forEach((title, info) => print(title + info.toString()));
    response.forEach((title, info) => addSongToListFull(
        allSongs,
        title,
        info['Artistas'],
        info['Albumes'],
        info['ImagenesAlbums'],
        info['url'],
        info["EsFavorita"]));
  } else {
    print('Error recuperando todas las canciones');
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
  print("Siguiendo $newFriend a $userName...");
  dynamic data = {'NombreUsuario': userName, 'Seguidor': newFriend};
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

Future<List> listFollowRequests() async {
  print("Recuperando solicitudes de amistad de  $userName");
  List followRequests = new List();
  dynamic response = await http.get(
      'https://playstack.azurewebsites.net/user/get/followrequests?Usuario=$userName');

  if (response.statusCode == 200) {
    response = jsonDecode(response.body);
    print("Solicitudes de amistad de $userName recuperadas");

    response.forEach((name, profilePhoto) => addUserToList(
          followRequests,
          name,
          profilePhoto['FotoDePerfil'],
        ));
  } else {
    print('Error buscando solicitudes de amistad ,body: ' +
        response.body.toString());
  }
  print("Tiene " + followRequests.length.toString() + " solicitudes");
  return followRequests;
}

Future<bool> sendFollowRequest(String newFriend) async {
  print("Enviando solicitud de seguimiento $userName a $newFriend...");
  dynamic data = {'NombreUsuario': userName, 'Seguido': newFriend};
  print("La data" + data.toString());

  data = jsonEncode(data);
  dynamic response = await http.post(
      "https://playstack.azurewebsites.net/user/add/followRequest",
      headers: {"Content-Type": "application/json"},
      body: data);

  print("Statuscode solicitud follow: " + response.statusCode.toString());

  if (response.statusCode == 200) {
    print("Solicitud enviada ");
    return true;
  } else {
    print("Solicitud no enviada, body: " + response.body.toString());
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
  List users = new List();

  print("Buscando usuario " + keyword);
  dynamic response = await http
      .get('https://playstack.azurewebsites.net/user/search?KeyWord=$keyword');
  if (response.statusCode == 200) {
    response = jsonDecode(response.body);
    print("Response " + response.toString());
    response.forEach((title, profilePhoto) => addUserToList(
          users,
          title,
          profilePhoto,
        ));
    users.remove(userName);
  } else {
    print('Error buscando usuarios');
  }
  return users;
}

Future<bool> setLastSongAsCurrent() async {
  dynamic response = await http.get(
      "https://playstack.azurewebsites.net/user/get/lastsong?Usuario=$userName");

  //print("Body:" + response.body.toString());
  if (response.statusCode == 200) {
    response = jsonDecode(response.body);
    //response.forEach((title, info) => print(title + info.toString()));
    currentAudio = new Song();
    response.forEach((title, info) => currentAudio.setInfo(
        title,
        info['Artistas'],
        info['url'],
        info['Albumes'],
        info['ImagenesAlbums'],
        info['Generos'],
        info['EsFavorita']));
    print("Ultima cancion seteada");
    return true;
  } else {
    print('Error cogiendo ultima cancion escuchada');
    return false;
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
      PlaylistType(title: name, coverUrls: covers, isPrivate: isPrivate);
  playlists.add(newPlaylist);
}

addFolderToList(List folders, String folderName, List containedPlaylists) {
  List playlists = new List();
  for (var playlist in containedPlaylists) {
    playlist.forEach((name, info) =>
        addPlaylistToList(playlists, name, info['Fotos'], info['Privado']));
  }
  FolderType newFolder =
      new FolderType(name: folderName, containedPlaylists: playlists);
  folders.add(newFolder);
}

Future<List> getUserFolders() async {
  List folders = new List();

  print("Recuperando carpetas de " + userName);
  dynamic response = await http.get(
      "https://playstack.azurewebsites.net/get/folders?NombreUsuario=$userName");

  print("Statuscode carpetas: " + response.statusCode.toString());

  if (response.statusCode == 200) {
    print("Carpetas recuperadas");
    response = json.decode(response.body);
    response.forEach(
        (name, playlists) => addFolderToList(folders, name, playlists));
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
    //response.forEach((name, covers) => print(name + covers.toString()));
    response.forEach((name, info) =>
        addPlaylistToList(playlists, name, info['Fotos'], info['Privado']));
    print("Tiene ${playlists.length.toString()} playlists");
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

    response.forEach((title, info) => addSongToListFull(
        favSongs,
        title,
        info['Artistas'],
        info['url'],
        info['Albumes'],
        info['ImagenesAlbums'],
        true));

    //title, info['Artistas'],info['url'], info['Albunes'], info['ImagenesAlbum']
  } else {
    print("Status code not 200, body: " + response.body);
  }
  print("Hay " + favSongs.length.toString() + " favoritas");
  return favSongs;
}

void markAsListenedDB(String songTitle) async {
  dynamic now = new DateTime.now();
  now = now.toString().substring(0, 19);
  now = now.replaceAll('-', '/');

  dynamic data = {'Usuario': userName, 'Titulo': songTitle, 'Timestamp': now};

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

Future<bool> getProfilePhoto() async {
  print("Recuperando foto de " + userName);
  dynamic response = await http.get(
      "https://playstack.azurewebsites.net/user/get/profilephoto?Usuario=$userName");

  print("Statuscode foto: " + response.statusCode.toString());

  if (response.statusCode == 200) {
    response = json.decode(response.body);
    print("Foto de perfil recuperada");
    imagePath = response['FotoDePerfil'];
    return true;
  } else {
    print("Error recuperando foto de perfil, body: " + response.body);
    return false;
  }
}

Future<List> getCollaboratorsDB() async {
  List collaborators = new List();
  List<Podcast> podcasts;
  podcasts = await getFollowedPodcastsDB();
  podcasts.forEach((Podcast p) => p.hosts.forEach((h) => collaborators.add(h)));
  return collaborators;
}

Future<List> getCollaboratorPodcastsDB(String collaborator) async {
  print("Recuperando podcasts con la presencia de $collaborator");

  List podcasts = new List();
  dynamic response = await http.get(
      'https://playstack.azurewebsites.net/get/podcast/byinterlocutor?NombreInterlocutor=$collaborator');

  if (response.statusCode == 200) {
    response = jsonDecode(response.body);
    print("Podcasts con la presencia de $collaborator recuperados");

    response.forEach((title, info) => podcasts.add(Podcast(
        title: title,
        coverUrl: info['Foto'],
        language: Language(info['Idioma']),
        hosts: info['Interlocutores'],
        desc: info['Descripcion'])));
  } else {
    print("Statuscode de podcasts con la colaboración de $collaborator" +
        response.statusCode.toString());
    print('Error buscando podcasts con colaboración de $collaborator, body: ' +
        response.body.toString());
  }
  print("Ha colaborado en " + podcasts.length.toString() + " podcasts");
  return podcasts;
}

Future<List<Podcast>> getFollowedPodcastsDB() async {
  print("Recuperando podcasts seguidos por $userName");

  List<Podcast> followed = new List();
  dynamic response = await http.get(
      'https://playstack.azurewebsites.net/get/podcast/followed?NombreUsuario=$userName');

  if (response.statusCode == 200) {
    response = jsonDecode(response.body);
    print("Podcasts suscritos de $userName recuperados");

    response.forEach((title, info) => followed.add(Podcast(
        title: title,
        coverUrl: info['Foto'],
        language: Language(info['Idioma']),
        hosts: info['Interlocutores'],
        desc: info['Descripcion'])));
  } else {
    print("Statuscode de podcasts suscritos de $userName" +
        response.statusCode.toString());
    print('Error buscando podcasts suscritos de $userName, body: ' +
        response.body.toString());
  }
  print("Sigue " + followed.length.toString() + " podcasts");
  return followed;
}

Future<List> getPodcastEpisodesDB(String podcast) async {
  print("Recuperando episodios de $podcast");

  List<Episode> episodes = new List();
  dynamic response = await http.get(
      'https://playstack.azurewebsites.net/get/podcast/all?NombrePodcast=$podcast');

  if (response.statusCode == 200) {
    response = jsonDecode(response.body);
    print("Episodios de $podcast recuperados");

    for (Map episodeMap in response['capitulos']) {
      episodes.add(Episode(
          number: episodeMap['numChapter'],
          artists: response['Interlocutores'],
          title: episodeMap['nombre'],
          albumCoverUrls: [response['Foto']],
          date: episodeMap['fecha'],
          duration: 0,
          url: episodeMap['url']));
    }
  } else {
    print(
        "Statuscode de episodios de $podcast" + response.statusCode.toString());
    print('Error buscando episodios de $podcast, body: ' +
        response.body.toString());
  }
  print("El podcast tiene " + episodes.length.toString() + " episodios");
  return episodes;
}
