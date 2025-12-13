import 'package:get/get.dart';
import 'package:music_player/model/playlist_model.dart';
import 'package:music_player/model/song_item.dart';

class PlaylistController extends GetxController {
  final RxList<PlaylistModel> playlists = <PlaylistModel>[].obs;

  void createPlaylist(String name) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    playlists.add(PlaylistModel(id: id, name: name));
  }

  void renamePlaylist(String id, String newName) {
    final idx = playlists.indexWhere((p) => p.id == id);
    if (idx != -1) {
      playlists[idx].name = newName;
      playlists.refresh();
    }
  }

  void deletePlaylist(String id) {
    playlists.removeWhere((p) => p.id == id);
  }

  void addSongToPlaylist(String playlistId, UnifiedSong song) {
    final idx = playlists.indexWhere((p) => p.id == playlistId);
    if (idx == -1) return;
    final playlist = playlists[idx];
    final exists = playlist.songs.any((s) => s.idKey == song.idKey);
    if (!exists) {
      playlist.songs.add(song);
      playlists.refresh();
    }
  }

  void removeSongFromPlaylist(String playlistId, String songIdKey) {
    final idx = playlists.indexWhere((p) => p.id == playlistId);
    if (idx == -1) return;
    playlists[idx].songs.removeWhere((s) => s.idKey == songIdKey);
    playlists.refresh();
  }
}
