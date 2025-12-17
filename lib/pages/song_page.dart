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

class SongPage extends StatefulWidget {
  const SongPage({super.key});

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
            child: _SearchBar(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SectionTitle(
              title: "All Songs",
              action: Obx(() {
                final isDevice = songDataController.isDeviceSong.value;
                final baseCount = isDevice
                    ? songDataController.localSongList.length
                    : cloudSongController.cloudSongList.length;
                final filteredCount = _filteredSongs(
                        isDevice ? songDataController.localSongList : null,
                        isDevice ? null : cloudSongController.cloudSongList)
                    .length;
                final visibleCount =
                    _searchQuery.isEmpty ? baseCount : filteredCount;

                return Text(
                  "$visibleCount tracks",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: label_color),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              final isDevice = songDataController.isDeviceSong.value;
              final songs = _filteredSongs(
                isDevice ? songDataController.localSongList : null,
                isDevice ? null : cloudSongController.cloudSongList,
              );

              if (songs.isEmpty) {
                return Center(
                  child: Text(
                    _searchQuery.isEmpty
                        ? (isDevice
                            ? "No local songs found."
                            : "No cloud songs available.")
                        : "No songs match your search.",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              }

              return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  final UnifiedSong unified = song is SongModel
                      ? UnifiedSong.fromLocal(song)
                      : UnifiedSong.fromCloud(song as MySongModel);

                  return Obx(() {
                    final isFavorite =
                        favoritesController.isFavorite(unified.idKey);
                    return SongTile(
                      songName: unified.title,
                      subtitle: unified.artist ??
                          (unified.isLocal ? "Local track" : "Cloud track"),
                      onPress: () {
                        if (unified.isLocal) {
                          songplayercontroller
                              .playLocalAudio(song as SongModel);
                          songDataController
                              .findCurrentPlayingSongId((song as SongModel).id);
                        } else {
                          songplayercontroller
                              .playCloudAudio(song as MySongModel);
                          songDataController.findCurrentPlayingSongId(
                              (song as MySongModel).id);
                        }
                        Get.to(const SongAndVolume());
                      },
                      onToggleFavorite: () =>
                          favoritesController.toggleFavorite(unified),
                      isFavorite: isFavorite,
                      onAddToPlaylist: () => showAddToPlaylistSheet(
                          context, playlistController, unified),
                    );
                  });
                },
              );
            }),
          ),
        ],
      ),
    ));
  }

  List<dynamic> _filteredSongs(
      List<SongModel>? localSongs, List<MySongModel>? cloudSongs) {
    final query = _searchQuery.toLowerCase();
    final List<dynamic> source = localSongs != null
        ? List<dynamic>.from(localSongs)
        : List<dynamic>.from(cloudSongs ?? []);

    if (query.isEmpty) return source;

    return source.where((song) {
      if (song is SongModel) {
        final title = song.title.toLowerCase();
        final artist = (song.artist ?? '').toLowerCase();
        return title.contains(query) || artist.contains(query);
      } else if (song is MySongModel) {
        final title = song.title.toLowerCase();
        return title.contains(query);
      }

      return false;
    }).toList();
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
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.search,
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color
                  ?.withOpacity(0.8)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.9),
                    fontSize: 14,
                  ),
              decoration: InputDecoration(
                hintText: "Search your music...",
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withOpacity(0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                onChanged('');
              },
              child: Icon(Icons.close,
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withOpacity(0.7),
                  size: 18),
            )
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
