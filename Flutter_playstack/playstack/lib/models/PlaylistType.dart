import 'package:playstack/services/database.dart';

class PlaylistType {
  String title;
  List coverUrls;
  bool isPrivate;
  PlaylistType({this.title, this.coverUrls, this.isPrivate});

  Future<void> changePlaylistStatus() async {
    bool updated =
        await updatePlaylistDB(this.title, this.title, !this.isPrivate);
    if (updated) {
      this.isPrivate = !this.isPrivate;
    }
  }

  Future<bool> changePlaylistName(String newName) async {
    bool updated = await updatePlaylistDB(this.title, newName, this.isPrivate);
    if (updated) {
      this.title = newName;
    }
    return updated;
  }

  Future<void> updateCovers() async {
    this.coverUrls = await updatePlaylistCoversDB(this.title);
  }
}
