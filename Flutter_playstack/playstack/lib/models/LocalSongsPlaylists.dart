// Clase para representar la relacion N:M entre canciones y playlist

class LocalSongsPlaylists {
  String id;
  String songName;
  String playlistName;
  LocalSongsPlaylists({this.id, this.songName, this.playlistName});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'songName': songName,
      'playlistName': playlistName,
    };
  }
}
