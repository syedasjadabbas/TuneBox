import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/config/colors.dart';
import 'package:music_player/controller/favorites_controller.dart';
import 'package:music_player/controller/playlist_controller.dart';
import 'package:music_player/controller/songPlayerController.dart';
import 'package:music_player/pages/favorites_page.dart';
import 'package:music_player/pages/playlists_page.dart';
import 'package:music_player/pages/song_page.dart';
import 'package:music_player/pages/profile_screen.dart';
import 'package:music_player/component/songAndVolume.dart';
import 'package:music_player/services/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;
  final _supabase = SupabaseService.client;

  @override
  void initState() {
    super.initState();
    // Ensure shared controllers are initialized once.
    Get.put(Songplayercontroller(), permanent: true);
    Get.put(FavoritesController(), permanent: true);
    Get.put(PlaylistController(), permanent: true);
    
    // Listen to auth state changes and refresh data
    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        // Refresh favorites and playlists when user signs in
        final favoritesController = Get.find<FavoritesController>();
        final playlistController = Get.find<PlaylistController>();
        favoritesController.refreshFavorites();
        playlistController.refreshPlaylists();
      } else if (event == AuthChangeEvent.signedOut) {
        // Clear data when user signs out
        final favoritesController = Get.find<FavoritesController>();
        final playlistController = Get.find<PlaylistController>();
        favoritesController.favorites.clear();
        playlistController.playlists.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final playerController = Get.find<Songplayercontroller>();

    final pages = const [
      SongPage(),
      FavoritesPage(),
      PlaylistsPage(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _index,
                children: pages,
              ),
            ),
            Obx(() {
              final hasSong =
                  playerController.currentSongTitle.value.isNotEmpty;
              if (!hasSong) return const SizedBox.shrink();
              return _MiniPlayerBar(controller: playerController);
            }),
            _BottomNav(
              currentIndex: _index,
              onTap: (i) => setState(() => _index = i),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : div_color,
      selectedItemColor: primary_color,
      unselectedItemColor: Theme.of(context).brightness == Brightness.light
          ? Colors.black54
          : label_color,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"),
        BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border), label: "Favorites"),
        BottomNavigationBarItem(
            icon: Icon(Icons.playlist_play), label: "Playlists"),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: "Profile"),
      ],
    );
  }
}

class _MiniPlayerBar extends StatelessWidget {
  final Songplayercontroller controller;
  const _MiniPlayerBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF2F313A),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.black.withOpacity(0.05)
              : Colors.white.withOpacity(0.05),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
                Theme.of(context).brightness == Brightness.light ? 0.04 : 0.12),
            blurRadius: 4,
            offset: const Offset(0, -1),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? primary_color.withOpacity(0.10)
                  : primary_color.withOpacity(0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.music_note, color: primary_color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.currentSongTitle.value,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      controller.currentArtist.value,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withOpacity(0.8)),
                    )
                  ],
                )),
          ),
          Obx(
            () => IconButton(
              icon: Icon(
                  controller.isPlaying.value
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: primary_color,
                  size: 30),
              onPressed: () {
                if (controller.isPlaying.value) {
                  controller.pausePlaying();
                } else {
                  controller.resumePlaying();
                }
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.open_in_full,
                color: Theme.of(context).iconTheme.color),
            onPressed: () => Get.to(const SongAndVolume()),
          )
        ],
      ),
    );
  }
}
