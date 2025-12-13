import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/component/songAndVolume.dart';
import 'package:music_player/component/song_tile.dart';
import 'package:music_player/config/colors.dart';
import 'package:music_player/controller/cloudSongController.dart';
import 'package:music_player/controller/favorites_controller.dart';
import 'package:music_player/controller/playlist_controller.dart';
import 'package:music_player/controller/songPlayerController.dart';
import 'package:music_player/controller/songdatacontroller.dart';
import 'package:music_player/model/mySongModel.dart';
import 'package:music_player/model/song_item.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SongPage extends StatelessWidget {
  const SongPage({super.key});

  @override
  Widget build(BuildContext context) {
    SongDataController songDataController = Get.put(SongDataController());
    Songplayercontroller songplayercontroller = Get.find();
    CloudSongController cloudSongController = Get.put(CloudSongController());
    FavoritesController favoritesController = Get.find();
    PlaylistController playlistController = Get.find();

    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          _Header(songDataController: songDataController),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _SearchBar(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SectionTitle(
              title: "All Songs",
              action: Obx(() => Text(
                    songDataController.isDeviceSong.value
                        ? "${songDataController.localSongList.length} tracks"
                        : "${cloudSongController.cloudSongList.length} tracks",
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: label_color),
                  )),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              final isDevice = songDataController.isDeviceSong.value;
              if ((isDevice
                      ? songDataController.localSongList
                      : cloudSongController.cloudSongList)
                  .isEmpty) {
                return Center(
                  child: Text(
                    isDevice
                        ? "No local songs found."
                        : "No cloud songs available.",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              }

              return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: isDevice
                    ? songDataController.localSongList.length
                    : cloudSongController.cloudSongList.length,
                itemBuilder: (context, index) {
                  if (isDevice) {
                    final SongModel song =
                        songDataController.localSongList[index];
                    final UnifiedSong unified = UnifiedSong.fromLocal(song);
                    return SongTile(
                      songName: song.title,
                      subtitle: song.artist ?? "Local track",
                      onPress: () {
                        songplayercontroller.playLocalAudio(song);
                        songDataController.findCurrentPlayingSongId(song.id);
                        Get.to(const SongAndVolume());
                      },
                      onToggleFavorite: () =>
                          favoritesController.toggleFavorite(unified),
                      isFavorite:
                          favoritesController.isFavorite(unified.idKey),
                      onAddToPlaylist: () => showAddToPlaylistSheet(
                          context, playlistController, unified),
                    );
                  } else {
                    final MySongModel song =
                        cloudSongController.cloudSongList[index];
                    final UnifiedSong unified = UnifiedSong.fromCloud(song);
                    return SongTile(
                      songName: song.title,
                      subtitle: "Cloud track",
                      onPress: () {
                        songplayercontroller.playCloudAudio(song);
                        songDataController.findCurrentPlayingSongId(song.id);
                        Get.to(const SongAndVolume());
                      },
                      onToggleFavorite: () =>
                          favoritesController.toggleFavorite(unified),
                      isFavorite:
                          favoritesController.isFavorite(unified.idKey),
                      onAddToPlaylist: () => showAddToPlaylistSheet(
                          context, playlistController, unified),
                    );
                  }
                },
              );
            }),
          ),
        ],
      ),
    ));
  }
}

void showAddToPlaylistSheet(BuildContext context,
    PlaylistController playlistController, UnifiedSong song) {
  showModalBottomSheet(
    context: context,
    backgroundColor: div_color,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Add to playlist",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: primary_color),
                ),
                TextButton(
                  onPressed: () {
                    _showCreatePlaylistDialog(context, playlistController);
                  },
                  child: const Text("New"),
                )
              ],
            ),
            const SizedBox(height: 10),
            Obx(() {
              if (playlistController.playlists.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    "No playlists yet.",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: playlistController.playlists.length,
                itemBuilder: (context, index) {
                  final playlist = playlistController.playlists[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(playlist.name),
                    subtitle:
                        Text("${playlist.songs.length} songs"),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        playlistController.addSongToPlaylist(
                            playlist.id, song);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              );
            }),
          ],
        ),
      );
    },
  );
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
          decoration:
              const InputDecoration(hintText: "Playlist name"),
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

class _Header extends StatelessWidget {
  final SongDataController songDataController;
  const _Header({required this.songDataController});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [gradient_start, gradient_end],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "TuneBox",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Obx(() => Text(
                      songDataController.isDeviceSong.value
                          ? "Device"
                          : "Cloud",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.white),
                    )),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Obx(
            () => Row(
              children: [
                _ToggleChip(
                  label: "Local",
                  selected: songDataController.isDeviceSong.value,
                  onTap: () => songDataController.isDeviceSong.value = true,
                ),
                const SizedBox(width: 10),
                _ToggleChip(
                  label: "Cloud",
                  selected: !songDataController.isDeviceSong.value,
                  onTap: () => songDataController.isDeviceSong.value = false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: selected ? Colors.black : Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: div_color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: label_color),
          const SizedBox(width: 10),
          Text(
            "Search your music...",
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: label_color),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? action;
  const _SectionTitle({required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: primary_color,
              ),
        ),
        if (action != null) action!,
      ],
    );
  }
}
