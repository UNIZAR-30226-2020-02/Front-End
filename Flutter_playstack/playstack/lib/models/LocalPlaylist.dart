class LocalPlaylist {
  String name;

  LocalPlaylist({this.name});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}
