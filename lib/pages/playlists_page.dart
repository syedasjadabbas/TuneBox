import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/component/song_tile.dart';
import 'package:music_player/config/colors.dart';
import 'package:music_player/controller/playlist_controller.dart';
import 'package:music_player/controller/songPlayerController.dart';
import 'package:music_player/model/playlist_model.dart';
import 'package:music_player/model/song_item.dart';
import 'package:music_player/pages/song_page.dart';

class PlaylistsPage extends StatelessWidget {
  const PlaylistsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final playlistController = Get.find<PlaylistController>();
    final playerController = Get.find<Songplayercontroller>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Playlists"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _showCreatePlaylistDialog(context, playlistController),
        backgroundColor: primary_color,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Obx(() {
        if (playlistController.playlists.isEmpty) {
          return Center(
            child: Text(
              "No playlists yet.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: playlistController.playlists.length,
          itemBuilder: (context, index) {
            final playlist = playlistController.playlists[index];
            return _PlaylistCard(
              playlist: playlist,
              onTap: () {
                Get.to(() => PlaylistDetailPage(playlistId: playlist.id));
              },
              onDelete: () =>
                  playlistController.deletePlaylist(playlist.id),
              onRename: () => _showRenameDialog(
                  context, playlistController, playlist.id, playlist.name),
            );
          },
        );
      }),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  final PlaylistModel playlist;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onRename;
  const _PlaylistCard(
      {required this.playlist,
      required this.onTap,
      required this.onDelete,
      required this.onRename});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        onTap: onTap,
        title: Text(playlist.name),
        subtitle: Text("${playlist.songs.length} songs"),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == "rename") onRename();
            if (value == "delete") onDelete();
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: "rename", child: Text("Rename")),
            PopupMenuItem(value: "delete", child: Text("Delete")),
          ],
        ),
      ),
    );
  }
}

class PlaylistDetailPage extends StatelessWidget {
  final String playlistId;
  const PlaylistDetailPage({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context) {
    final playlistController = Get.find<PlaylistController>();
    final playerController = Get.find<Songplayercontroller>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Playlist"),
      ),
      body: Obx(() {
        final playlist = playlistController.playlists
            .firstWhereOrNull((p) => p.id == playlistId);
        if (playlist == null) {
          return Center(
            child: Text("Playlist not found",
                style: Theme.of(context).textTheme.bodySmall),
          );
        }
        if (playlist.songs.isEmpty) {
          return Center(
            child: Text("No songs yet.",
                style: Theme.of(context).textTheme.bodySmall),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: playlist.songs.length,
          itemBuilder: (context, index) {
            final song = playlist.songs[index];
            return SongTile(
              songName: song.title,
              subtitle: song.artist ?? "",
              onPress: () {
                playerController.playUnifiedSong(song);
              },
              isFavorite: true,
              onToggleFavorite: () => playlistController
                  .removeSongFromPlaylist(playlistId, song.idKey),
              onAddToPlaylist: null,
            );
          },
        );
      }),
    );
  }
}

void _showCreatePlaylistDialog(
    BuildContext context, PlaylistController playlistController) {
  final controller = TextEditingController();
  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text("Create playlist"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Playlist name"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                playlistController.createPlaylist(controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text("Create"),
          )
        ],
      );
    },
  );
}

void _showRenameDialog(BuildContext context,
    PlaylistController playlistController, String id, String currentName) {
  final controller = TextEditingController(text: currentName);
  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text("Rename playlist"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "New name"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                playlistController.renamePlaylist(id, controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      );
    },
  );
}
