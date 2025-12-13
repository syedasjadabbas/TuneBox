import 'package:music_player/model/mySongModel.dart';
import 'package:on_audio_query/on_audio_query.dart';

class UnifiedSong {
  final String idKey;
  final String title;
  final String? artist;
  final bool isLocal;
  final String data;
  final SongModel? localSong;
  final MySongModel? cloudSong;

  UnifiedSong({
    required this.idKey,
    required this.title,
    required this.artist,
    required this.isLocal,
    required this.data,
    this.localSong,
    this.cloudSong,
  });

  factory UnifiedSong.fromLocal(SongModel song) {
    return UnifiedSong(
      idKey: "local-${song.id}",
      title: song.title,
      artist: song.artist,
      isLocal: true,
      data: song.data,
      localSong: song,
    );
  }

  factory UnifiedSong.fromCloud(MySongModel song) {
    return UnifiedSong(
      idKey: "cloud-${song.id}",
      title: song.title,
      artist: "Cloud track",
      isLocal: false,
      data: song.data,
      cloudSong: song,
    );
  }
}
