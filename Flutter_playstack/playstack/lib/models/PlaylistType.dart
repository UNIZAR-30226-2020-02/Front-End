import 'package:playstack/services/database.dart';

class PlaylistType {
  String name;
  List coverUrls;
  bool isPrivate;
  PlaylistType({this.name, this.coverUrls, this.isPrivate});

  Future<void> changePlaylistStatus() async {
    bool updated =
        await updatePlaylistDB(this.name, this.name, !this.isPrivate);
    if (updated) {
      this.isPrivate = !this.isPrivate;
    }
  }

  Future<bool> changePlaylistName(String newName) async {
    bool updated = await updatePlaylistDB(this.name, newName, this.isPrivate);
    if (updated) {
      this.name = newName;
    }
    return updated;
  }

  Future<void> updateCovers() async {
    this.coverUrls = await updatePlaylistCoversDB(this.name);
  }
}
