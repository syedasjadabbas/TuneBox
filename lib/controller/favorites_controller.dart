import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:music_player/model/song_item.dart';
import 'package:music_player/services/supabase_client.dart';
import 'package:music_player/controller/cloudSongController.dart';
import 'package:music_player/controller/songdatacontroller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesController extends GetxController {
  final RxList<UnifiedSong> favorites = <UnifiedSong>[].obs;
  final _supabase = SupabaseService.client;

  @override
  void onInit() {
    super.onInit();
    // Wait a bit for other controllers to initialize
    Future.delayed(Duration(milliseconds: 500), () {
      _loadFavorites();
    });
  }

  Future<void> _loadFavorites() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase.rpc('get_my_favorites');
      
      favorites.clear();
      if (response != null) {
        final List<dynamic> favoritesList = response as List;
        
        // Get references to song controllers
        final cloudController = Get.find<CloudSongController>();
        final localController = Get.find<SongDataController>();
        
        for (var fav in favoritesList) {
          final songIdKey = fav['song_id_key'] as String;
          final songTitle = fav['song_title'] as String;
          final songArtist = fav['song_artist'] as String?;
          
          UnifiedSong? unifiedSong;
          
          if (songIdKey.startsWith('local-')) {
            // Extract local song ID
            final localId = int.tryParse(songIdKey.replaceFirst('local-', ''));
            if (localId != null) {
              final localSong = localController.localSongList.firstWhereOrNull(
                (s) => s.id == localId,
              );
              if (localSong != null) {
                unifiedSong = UnifiedSong.fromLocal(localSong);
              }
            }
          } else if (songIdKey.startsWith('cloud-')) {
            // Extract cloud song ID
            final cloudId = int.tryParse(songIdKey.replaceFirst('cloud-', ''));
            if (cloudId != null) {
              final cloudSong = cloudController.cloudSongList.firstWhereOrNull(
                (s) => s.id == cloudId,
              );
              if (cloudSong != null) {
                unifiedSong = UnifiedSong.fromCloud(cloudSong);
              }
            }
          }
          
          // If we couldn't find the song, create a placeholder
          if (unifiedSong == null) {
            unifiedSong = UnifiedSong(
              idKey: songIdKey,
              title: songTitle,
              artist: songArtist,
              isLocal: songIdKey.startsWith('local-'),
              data: '', // Will be filled when song is found
            );
          }
          
          favorites.add(unifiedSong);
        }
      }
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  bool isFavorite(String idKey) =>
      favorites.any((element) => element.idKey == idKey);

  Future<void> toggleFavorite(UnifiedSong song) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        Get.snackbar('Error', 'Please sign in to add favorites');
        return;
      }

      final isCurrentlyFavorite = isFavorite(song.idKey);
      
      if (isCurrentlyFavorite) {
        // Remove from Supabase
        await _supabase
            .from('favorites')
            .delete()
            .eq('user_id', userId)
            .eq('song_id_key', song.idKey);
        
        // Remove from local list
        favorites.removeWhere((element) => element.idKey == song.idKey);
      } else {
        // Add to Supabase using RPC
        await _supabase.rpc('toggle_favorite', params: {
          'p_song_id_key': song.idKey,
          'p_song_title': song.title,
          'p_song_artist': song.artist,
        });
        
        // Add to local list
        favorites.add(song);
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      Get.snackbar('Error', 'Failed to update favorite: $e');
    }
  }

  Future<void> refreshFavorites() async {
    await _loadFavorites();
  }
}
