import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/component/songAndVolume.dart';
import 'package:music_player/component/song_tile.dart';
import 'package:music_player/controller/favorites_controller.dart';
import 'package:music_player/controller/playlist_controller.dart';
import 'package:music_player/controller/songPlayerController.dart';
import 'package:music_player/model/song_item.dart';
import 'package:music_player/pages/song_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesController = Get.find<FavoritesController>();
    final playlistController = Get.find<PlaylistController>();
    final playerController = Get.find<Songplayercontroller>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorites"),
        centerTitle: true,
      ),
      body: Obx(() {
        if (favoritesController.favorites.isEmpty) {
          return Center(
            child: Text(
              "No favorites yet.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: favoritesController.favorites.length,
          itemBuilder: (context, index) {
            final song = favoritesController.favorites[index];
            return SongTile(
              songName: song.title,
              subtitle: song.artist ?? "",
              isFavorite: true,
              onPress: () => _playSong(playerController, song),
              onToggleFavorite: () =>
                  favoritesController.toggleFavorite(song),
              onAddToPlaylist: () =>
                  showAddToPlaylistSheet(context, playlistController, song),
            );
          },
        );
      }),
    );
  }

  void _playSong(Songplayercontroller controller, UnifiedSong song) {
    controller.playUnifiedSong(song);
    Get.to(const SongAndVolume());
  }
}
