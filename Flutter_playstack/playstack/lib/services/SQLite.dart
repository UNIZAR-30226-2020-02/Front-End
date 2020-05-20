import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:playstack/models/LocalPlaylist.dart';
import 'package:playstack/models/LocalSong.dart';
import 'package:playstack/models/LocalSongsPlaylists.dart';
import 'package:playstack/models/Song.dart';
import 'package:sqflite/sqflite.dart';
import 'package:playstack/shared/common.dart';
import 'package:toast/toast.dart';

Future _onConfigure(Database db) async {
  await db.execute('PRAGMA foreign_keys = ON');
}

void createLocalDatabase() async {
  // Abre la base de datos y guarda la referencia.
  database = openDatabase(

      // Establecer la ruta a la base de datos. Nota: Usando la función `join` del
      // complemento `path` es la mejor práctica para asegurar que la ruta sea correctamente
      // construida para cada plataforma.
      join(await getDatabasesPath(), 'local_music.db'),
      // Cuando la base de datos se crea por primera vez, crea una tabla para almacenar dogs
      onCreate: (db, version) async {
    await db.execute(
      "CREATE TABLE Songs(name TEXT PRIMARY KEY, path TEXT)",
    );
    await db.execute(
      "CREATE TABLE Playlists(name TEXT PRIMARY KEY)",
    );
    await db.execute(
        "CREATE TABLE SongsInPlaylists(id TEXT PRIMARY KEY, songName TEXT,playlistName TEXT)");
  },
      // Establece la versión. Esto ejecuta la función onCreate y proporciona una
      // ruta para realizar actualizacones y defradaciones en la base de datos.
      version: 1,
      onConfigure: _onConfigure);

  print("Base de datos local creada");
}

Future<void> dropAndCreate() async {
  final Database db = await database;

  try {
    await db.execute(
      "DROP TABLE SongsInPlaylists",
    );
    await db.execute(
      "DROP TABLE Songs",
    );
    await db.execute(
      "DROP TABLE Playlists",
    );
    await db.execute(
      "CREATE TABLE Songs(name TEXT PRIMARY KEY, path TEXT)",
    );
    await db.execute(
      "CREATE TABLE Playlists(name TEXT PRIMARY KEY)",
    );
    await db.execute(
        "CREATE TABLE SongsInPlaylists(id TEXT PRIMARY KEY, songName TEXT,playlistName TEXT)");
  } catch (e) {
    print("Excepcion insertando cancion local");
  }
}

Future<void> insertSong(LocalSong song) async {
  // Obtiene una referencia de la base de datos
  final Database db = await database;

  try {
    await db.insert(
      'Songs',
      song.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  } catch (e) {
    print("Excepcion insertando cancion local");
  }

  // Inserta el Dog en la tabla correcta. También puede especificar el
  // `conflictAlgorithm` para usar en caso de que el mismo Dog se inserte dos veces.
  // En este caso, reemplaza cualquier dato anterior.
}

Future<void> insertPlaylist(LocalPlaylist playlist) async {
  // Obtiene una referencia de la base de datos
  final Database db = await database;

  // Inserta el Dog en la tabla correcta. También puede especificar el
  // `conflictAlgorithm` para usar en caso de que el mismo Dog se inserte dos veces.
  // En este caso, reemplaza cualquier dato anterior.
  await db.insert(
    'Playlists',
    playlist.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<int> insertSongToPlaylist(LocalSongsPlaylists songPlaylist) async {
  // Obtiene una referencia de la base de datos
  final Database db = await database;
  int inserted = 0;

  try {
    inserted = await db.insert(
      'SongsInPlaylists',
      songPlaylist.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  } catch (e) {
    print("Excepcion metiendo cancion en playlist");
  }
  return inserted;
}

Future<List<LocalSong>> getLocalSongs() async {
  print("Recuperando canciones locales");

  // Obtiene una referencia de la base de datos
  final Database db = await database;

  // Consulta la tabla por todos los Dogs.
  final List<Map<String, dynamic>> maps = await db.query('Songs');

  // Convierte List<Map<String, dynamic> en List<Dog>.
  return List.generate(maps.length, (i) {
    return LocalSong(
      name: maps[i]['name'],
      path: maps[i]['path'],
    );
  });
}

Future<List<LocalPlaylist>> getLocalPlaylists() async {
  print("Recuperando playlists locales");
  // Obtiene una referencia de la base de datos
  final Database db = await database;

  // Consulta la tabla por todos los Dogs.
  final List<Map<String, dynamic>> maps = await db.query('Playlists');

  // Convierte List<Map<String, dynamic> en List<Dog>.
  return List.generate(maps.length, (i) {
    return LocalPlaylist(
      name: maps[i]['name'],
    );
  });
}

Future<List<LocalSongsPlaylists>> getSongsInPlaylists() async {
  // Obtiene una referencia de la base de datos
  final Database db = await database;

  // Consulta la tabla por todos los Dogs.
  final List<Map<String, dynamic>> maps = await db.query('SongsInPlaylists');

  // Convierte List<Map<String, dynamic> en List<Dog>.
  return List.generate(maps.length, (i) {
    return LocalSongsPlaylists(
        id: maps[i]['id'],
        songName: maps[i]['songName'],
        playlistName: maps[i]['playlistName']);
  });
}

Future<int> deleteLocalPlaylist(String name) async {
  print("Borrando playlist $name");
  final db = await database;
  int affectedRows = 0;
  try {
    affectedRows = await db.delete(
      'Playlists',
      // Utiliza la cláusula `where` para eliminar un dog específico
      where: "name = ?",
      // Pasa el id Dog a través de whereArg para prevenir SQL injection
      whereArgs: [name],
    );
  } catch (e) {
    print("Excepcion eliminando playlist local " + e.toString());
  }
  // Elimina el Dog de la base de datos

  return affectedRows;
}

Future<int> deleteLocalSong(String name) async {
  final db = await database;
  int affectedRows = 0;

  try {
    // Elimina el Dog de la base de datos
    affectedRows = await db.delete(
      'Songs',
      // Utiliza la cláusula `where` para eliminar un dog específico
      where: "name = ?",
      // Pasa el id Dog a través de whereArg para prevenir SQL injection
      whereArgs: [name],
    );
  } catch (e) {
    print("Excepcion eliminando cancion local " + e.toString());
  }

  return affectedRows;
}

Future<int> deleteSongFromPlaylist(String songName, String playlistName) async {
  // Obtiene una referencia de la base de datos
  final db = await database;
  int deleted = 0;

  try {
    deleted = await db.delete(
      'SongsInPlaylists',
      // Utiliza la cláusula `where` para eliminar un dog específico
      where: "songName = ? AND playlistName = ?",
      // Pasa el id Dog a través de whereArg para prevenir SQL injection
      whereArgs: [songName, playlistName],
    );
  } catch (e) {
    print("Excepcion eliminando cancion de playlist ${e.toString()}");
  }
  return deleted;
}

Future<int> updateLocalPlaylist(LocalPlaylist playlist) async {
  // Obtiene una referencia de la base de datos
  final db = await database;
  int updated = 0;

  try {
    // Actualiza el Dog dado
    updated = await db.update(
      'Playlists',
      playlist.toMap(),
      // Aseguúrate de que solo actualizarás el Dog con el id coincidente
      where: "id = ?",
      // Pasa el id Dog a través de whereArg para prevenir SQL injection
      whereArgs: [playlist.name],
    );
  } catch (e) {
    print(e.toString());
  }

  return updated;
}

Future<void> deleteLocalSongFromEveryWhere(
    Song song, BuildContext context) async {
  List playlistsContainingSong = new List();
  List<LocalSongsPlaylists> _tmpList = await getSongsInPlaylists();
  for (var item in _tmpList) {
    print("Relacion " + item.toString());
  }

  for (var item in _tmpList) {
    if (item.songName == song.title)
      playlistsContainingSong.add(item.playlistName);
  }
  for (var playlistName in playlistsContainingSong) {
    deleteSongFromPlaylist(song.title, playlistName);
  }

  int removed = await deleteLocalSong(song.title);
  if (removed > 0) {
    Toast.show('Canción eliminada de la aplicación', context,
        gravity: Toast.CENTER,
        duration: Toast.LENGTH_LONG,
        backgroundColor: Colors.green);
  } else {
    Toast.show('Error eliminando canción', context,
        gravity: Toast.CENTER,
        duration: Toast.LENGTH_LONG,
        backgroundColor: Colors.red);
  }
}
