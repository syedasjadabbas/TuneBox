import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:music_player/model/playlist_model.dart';
import 'package:music_player/model/song_item.dart';
import 'package:music_player/services/supabase_client.dart';
import 'package:music_player/controller/cloudSongController.dart';
import 'package:music_player/controller/songdatacontroller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlaylistController extends GetxController {
  final RxList<PlaylistModel> playlists = <PlaylistModel>[].obs;
  final _supabase = SupabaseService.client;

  @override
  void onInit() {
    super.onInit();
    // Wait a bit for other controllers to initialize
    Future.delayed(Duration(milliseconds: 500), () {
      _loadPlaylists();
    });
  }

  UnifiedSong? _reconstructSong(String songIdKey, String songTitle, String? songArtist) {
    try {
      final cloudController = Get.find<CloudSongController>();
      final localController = Get.find<SongDataController>();
      
      if (songIdKey.startsWith('local-')) {
        final localId = int.tryParse(songIdKey.replaceFirst('local-', ''));
        if (localId != null) {
          final localSong = localController.localSongList.firstWhereOrNull(
            (s) => s.id == localId,
          );
          if (localSong != null) {
            return UnifiedSong.fromLocal(localSong);
          }
        }
      } else if (songIdKey.startsWith('cloud-')) {
        final cloudId = int.tryParse(songIdKey.replaceFirst('cloud-', ''));
        if (cloudId != null) {
          final cloudSong = cloudController.cloudSongList.firstWhereOrNull(
            (s) => s.id == cloudId,
          );
          if (cloudSong != null) {
            return UnifiedSong.fromCloud(cloudSong);
          }
        }
      }
      
      // Return placeholder if song not found
      return UnifiedSong(
        idKey: songIdKey,
        title: songTitle,
        artist: songArtist,
        isLocal: songIdKey.startsWith('local-'),
        data: '',
      );
    } catch (e) {
      print('Error reconstructing song: $e');
      return UnifiedSong(
        idKey: songIdKey,
        title: songTitle,
        artist: songArtist,
        isLocal: songIdKey.startsWith('local-'),
        data: '',
      );
    }
  }

  Future<void> _loadPlaylists() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Fetch playlists
      final playlistsResponse = await _supabase
          .from('playlists')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      playlists.clear();

      if (playlistsResponse != null) {
        final List<dynamic> playlistsList = playlistsResponse as List;
        
        for (var playlistData in playlistsList) {
          final playlistId = playlistData['id'] as String;
          
          // Fetch songs for this playlist
          final songsResponse = await _supabase
              .from('playlist_songs')
              .select()
              .eq('playlist_id', playlistId)
              .order('position', ascending: true);

          final List<UnifiedSong> songs = [];
          if (songsResponse != null) {
            final List<dynamic> songsList = songsResponse as List;
            for (var songData in songsList) {
              final songIdKey = songData['song_id_key'] as String;
              final songTitle = songData['song_title'] as String;
              final songArtist = songData['song_artist'] as String?;
              
              final unifiedSong = _reconstructSong(songIdKey, songTitle, songArtist);
              if (unifiedSong != null) {
                songs.add(unifiedSong);
              }
            }
          }

          playlists.add(PlaylistModel(
            id: playlistId,
            name: playlistData['name'] as String,
            songs: songs,
          ));
        }
      }
    } catch (e) {
      print('Error loading playlists: $e');
    }
  }

  Future<void> createPlaylist(String name) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        Get.snackbar('Error', 'Please sign in to create playlists');
        return;
      }

      final response = await _supabase.rpc('create_playlist', params: {
        'p_name': name,
      });

      if (response != null) {
        final playlistData = response as Map<String, dynamic>;
        playlists.add(PlaylistModel(
          id: playlistData['id'] as String,
          name: playlistData['name'] as String,
        ));
        playlists.refresh();
      }
    } catch (e) {
      print('Error creating playlist: $e');
      Get.snackbar('Error', 'Failed to create playlist: $e');
    }
  }

  Future<void> renamePlaylist(String id, String newName) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.rpc('rename_playlist', params: {
        'p_playlist_id': id,
        'p_new_name': newName,
      });

      final idx = playlists.indexWhere((p) => p.id == id);
      if (idx != -1) {
        playlists[idx].name = newName;
        playlists.refresh();
      }
    } catch (e) {
      print('Error renaming playlist: $e');
      Get.snackbar('Error', 'Failed to rename playlist: $e');
    }
  }

  Future<void> deletePlaylist(String id) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.rpc('delete_playlist', params: {
        'p_playlist_id': id,
      });

      playlists.removeWhere((p) => p.id == id);
      playlists.refresh();
    } catch (e) {
      print('Error deleting playlist: $e');
      Get.snackbar('Error', 'Failed to delete playlist: $e');
    }
  }

  Future<void> addSongToPlaylist(String playlistId, UnifiedSong song) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        Get.snackbar('Error', 'Please sign in to add songs to playlists');
        return;
      }

      await _supabase.rpc('add_song_to_playlist', params: {
        'p_playlist_id': playlistId,
        'p_song_id_key': song.idKey,
        'p_song_title': song.title,
        'p_song_artist': song.artist,
      });

      final idx = playlists.indexWhere((p) => p.id == playlistId);
      if (idx != -1) {
        final playlist = playlists[idx];
        final exists = playlist.songs.any((s) => s.idKey == song.idKey);
        if (!exists) {
          playlist.songs.add(song);
          playlists.refresh();
        }
      }
    } catch (e) {
      print('Error adding song to playlist: $e');
      Get.snackbar('Error', 'Failed to add song to playlist: $e');
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songIdKey) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.rpc('remove_song_from_playlist', params: {
        'p_playlist_id': playlistId,
        'p_song_id_key': songIdKey,
      });

      final idx = playlists.indexWhere((p) => p.id == playlistId);
      if (idx != -1) {
        playlists[idx].songs.removeWhere((s) => s.idKey == songIdKey);
        playlists.refresh();
      }
    } catch (e) {
      print('Error removing song from playlist: $e');
      Get.snackbar('Error', 'Failed to remove song from playlist: $e');
    }
  }

  Future<void> refreshPlaylists() async {
    await _loadPlaylists();
  }
}
