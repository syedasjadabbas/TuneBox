// ------------------- SONG MODEL -------------------
class Song {
  final String title;
  final String artist;
  final String url;
  final String image;

  Song({
    required this.title,
    required this.artist,
    required this.url,
    required this.image,
  });
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Song &&
              runtimeType == other.runtimeType &&
              url == other.url;

  @override
  int get hashCode => url.hashCode;
}

