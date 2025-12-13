import 'package:music_player/model/song_item.dart';

class PlaylistModel {
  final String id;
  String name;
  final List<UnifiedSong> songs;

  PlaylistModel({
    required this.id,
    required this.name,
    List<UnifiedSong>? songs,
  }) : songs = songs ?? [];
}
