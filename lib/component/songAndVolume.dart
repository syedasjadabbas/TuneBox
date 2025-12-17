import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/config/colors.dart';
import 'package:music_player/controller/favorites_controller.dart';
import 'package:music_player/controller/songPlayerController.dart';
import 'package:music_player/controller/songdatacontroller.dart';

class SongAndVolume extends StatefulWidget {
  const SongAndVolume({super.key});

  @override
  State<SongAndVolume> createState() => _SongAndVolumeState();
}

class _SongAndVolumeState extends State<SongAndVolume> {
  double _volumeValue = 50;

  @override
  Widget build(BuildContext context) {
    SongDataController songDataController = Get.put(SongDataController());
    final Songplayercontroller songplayercontroller = Get.find();
    final FavoritesController favoritesController = Get.find();

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [gradient_start, gradient_end],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.keyboard_arrow_down,
                                color: Colors.white),
                          ),
                          Text(
                            "Now Playing",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      _ArtworkPlaceholder(),
                      const SizedBox(height: 20),
                      Obx(
                        () => Column(
                          children: [
                    Text(
                      songplayercontroller.currentSongTitle.value.isEmpty
                          ? "Unknown Track"
                          : songplayercontroller.currentSongTitle.value,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                              fontSize: 22,
                              color: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.color),
                    ),
                            const SizedBox(height: 6),
                            Text(
                              songplayercontroller.currentArtist.value.isEmpty
                                  ? "Unknown Artist"
                                  : songplayercontroller.currentArtist.value,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Obx(() {
                        final duration = songplayercontroller.player.duration;
                        final position = songplayercontroller.player.position;

                        double max = duration?.inSeconds.toDouble() ?? 0;
                        double currentPosition = position.inSeconds.toDouble();
                        currentPosition = currentPosition.clamp(0, max);

                        return Column(
                          children: [
                            Slider(
                              value: currentPosition,
                              min: 0,
                              max: max,
                              divisions: max > 0 ? max.toInt() : null,
                              label: '${currentPosition.toInt()}s',
                              onChanged: (value) {
                                songplayercontroller
                                    .changeDurationToSecond(value.toInt());
                              },
                              activeColor:
                                  Theme.of(context).colorScheme.primary,
                              inactiveColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.3),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  songplayercontroller.currentTime.value,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  songplayercontroller.totalTime.value,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.skip_previous_rounded,
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.black87
                                  : Colors.white,
                            ),
                            iconSize: 40,
                            onPressed: () {
                              songDataController.playPreviousSong();
                            },
                          ),
                          const SizedBox(width: 12),
                          Obx(
                            () => ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary_color,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(18),
                              ),
                              onPressed: () {
                                if (songplayercontroller.isPlaying.value) {
                                  songplayercontroller.pausePlaying();
                                } else {
                                  songplayercontroller.resumePlaying();
                                }
                              },
                              child: Icon(
                                songplayercontroller.isPlaying.value
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: Icon(
                              Icons.skip_next_rounded,
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.black87
                                  : Colors.white,
                            ),
                            iconSize: 40,
                            onPressed: () {
                              songDataController.playNextSong();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Obx(
                            () => _CircleIconButton(
                              icon: songplayercontroller.isShuffled.value
                                  ? Icons.shuffle_on
                                  : Icons.shuffle,
                              active: songplayercontroller.isShuffled.value,
                              label: "Shuffle",
                              onTap: () => songplayercontroller.playRandomSong(),
                            ),
                          ),
                          Obx(
                            () => _CircleIconButton(
                              icon: songplayercontroller.isLoop.value
                                  ? Icons.repeat_on
                                  : Icons.repeat_one,
                              active: songplayercontroller.isLoop.value,
                              label: "Repeat",
                              onTap: () => songplayercontroller.setLoopSong(),
                            ),
                          ),
                          _CircleIconButton(
                            icon: Icons.volume_up,
                            active: false,
                            label: "Volume",
                            onTap: () =>
                                _showVolumeDialog(context, songplayercontroller),
                          ),
                          Obx(() {
                            final currentSong =
                                songplayercontroller.currentSong.value;
                            final isFavorite = currentSong != null &&
                                favoritesController
                                    .isFavorite(currentSong.idKey);
                            return _CircleIconButton(
                              icon: isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              active: isFavorite,
                              label: "Favorite",
                              onTap: () {
                                if (currentSong != null) {
                                  favoritesController
                                      .toggleFavorite(currentSong);
                                } else {
                                  Get.snackbar(
                                      'No song', 'Play a song first.');
                                }
                              },
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showVolumeDialog(
      BuildContext context, Songplayercontroller controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adjust Volume'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: _volumeValue,
                min: 0,
                max: 100,
                divisions: 100,
                label: _volumeValue.toInt().toString(),
                onChanged: (value) {
                  setState(() {
                    _volumeValue = value;
                  });
                  controller.player.setVolume(_volumeValue / 100);
                },
                activeColor: Colors.blue,
                inactiveColor: Colors.blue.withOpacity(0.5),
              ),
              Text(
                '${_volumeValue.toInt()}%',
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class _ArtworkPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(
        child: Icon(
          Icons.album,
          color: primary_color,
          size: 70,
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final String label;
  const _CircleIconButton(
      {required this.icon,
      required this.active,
      required this.onTap,
      this.label = ''});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final button = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active
              ? primary_color.withOpacity(isLight ? 0.15 : 0.18)
              : (isLight
                  ? Colors.black.withOpacity(0.06)
                  : Colors.white.withOpacity(0.08)),
        ),
        child: Icon(
          icon,
          color: active
              ? primary_color
              : (isLight ? Colors.black87 : Colors.white),
        ),
      ),
    );

    if (label.isEmpty) return button;
    return Tooltip(message: label, child: button);
  }
}
