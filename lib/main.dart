import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'device_tab.dart';
import 'library_screen.dart';
import 'audio_manager.dart';
import 'song.dart';
import 'profile_screen.dart';
import 'playlists_screen.dart';

void main() {
  runApp(const TuneBoxApp());
}

class TuneBoxApp extends StatelessWidget {
  const TuneBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TuneBox',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(primary: Colors.redAccent),
      ),
      home: const SplashScreen(),
    );
  }
}

// ------------------- SPLASH SCREEN -------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.music_note, color: Colors.redAccent, size: 90),
            SizedBox(height: 20),
            Text(
              'TuneBox',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= MAIN SCREEN =================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final AudioManager _audioManager;

  final List<Song> _playlist = [
    Song(
      title: 'Shape of You',
      artist: 'Ed Sheeran',
      url: 'assets/audio/song1.mp3',
      image: 'assets/images/song1.jpg',
    ),
    Song(
      title: 'tv off',
      artist: 'Kendrick Lamar',
      url: 'assets/audio/song2.mp3',
      image: 'assets/images/song2.jpg',
    ),
    Song(
      title: 'Believer',
      artist: 'Imagine Dragons',
      url: 'assets/audio/song3.mp3',
      image: 'assets/images/song3.jpg',
    ),
    Song(
      title: 'Happy Nation',
      artist: 'Ace of Base',
      url: 'assets/audio/song4.mp3',
      image: 'assets/images/song4.jpg',
    ),
    Song(
      title: 'Perfect',
      artist: 'Ed Sheeran',
      url: 'assets/audio/song5.mp3',
      image: 'assets/images/song5.jpg',
    ),
    Song(
      title: 'Star Boys',
      artist: 'Weeknd',
      url: 'assets/audio/song6.mp3',
      image: 'assets/images/song6.jpg',
    ),
    Song(
      title: 'Fein',
      artist: 'Travis Scott',
      url: 'assets/audio/song7.mp3',
      image: 'assets/images/song7.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _audioManager = AudioManager();
    _audioManager.initialize(_playlist);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(playlist: _playlist, audioManager: _audioManager),
      const LibraryScreen(),
      PlaylistsScreen(allSongs: _playlist),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.white54,
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.playlist_play),
            label: 'Playlists',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ================= HOME SCREEN =================

class HomeScreen extends StatefulWidget {
  final List<Song> playlist;
  final AudioManager audioManager;

  const HomeScreen({
    super.key,
    required this.playlist,
    required this.audioManager,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openNowPlaying() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NowPlayingScreen(audioManager: widget.audioManager),
      ),
    );
  }

  Future<void> _playSong(Song song) async {
    final index = widget.playlist.indexOf(song);
    if (index != -1) {
      await widget.audioManager.playSelected(index);
      if (mounted) {
        _openNowPlaying();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TuneBox',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.redAccent, Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.redAccent,
          tabs: const [
            Tab(text: 'LOCAL'),
            Tab(text: 'DEVICE'),
            Tab(text: 'ONLINE'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _LocalTab(
                  playlist: widget.playlist,
                  audioManager: widget.audioManager,
                  onSongTap: _playSong,
                ),
                DeviceTab(),
                _OnlineTab(
                  playlist: widget.playlist,
                  onSongTap: _playSong,
                  recentlyPlayed: widget.audioManager.recentlyPlayed,
                ),
              ],
            ),
          ),
          MiniPlayer(audioManager: widget.audioManager, onTap: _openNowPlaying),
        ],
      ),
    );
  }
}

// ================= TAB WIDGETS =================

class _LocalTab extends StatelessWidget {
  final List<Song> playlist;
  final AudioManager audioManager;
  final Future<void> Function(Song) onSongTap;

  const _LocalTab({
    required this.playlist,
    required this.audioManager,
    required this.onSongTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: audioManager,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SearchField(hintText: 'Search local music...'),
              const SizedBox(height: 25),
              const Text(
                'Recently Played',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 15),
              _HorizontalSongList(
                songs: audioManager.recentlyPlayed,
                onSongTap: onSongTap,
              ),
              const SizedBox(height: 25),
              const Text(
                'All Local Songs',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 15),
              _HorizontalSongList(songs: playlist, onSongTap: onSongTap),
            ],
          ),
        );
      },
    );
  }
}

/////online tab///////
class _OnlineTab extends StatelessWidget {
  final List<Song> playlist;
  final Future<void> Function(Song) onSongTap;
  final List<Song> recentlyPlayed;

  const _OnlineTab({
    Key? key,
    required this.playlist,
    required this.onSongTap,
    required this.recentlyPlayed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy online songs (no images needed for now)
    final dummyOnlineSongs = [
      Song(
        title: 'Online Song 1',
        artist: 'Artist 1',
        url: '',
        image: 'assets/images/cover1.jpg',
      ),
      Song(
        title: 'Online Song 2',
        artist: 'Artist 2',
        url: '',
        image: 'assets/images/cover5.jpg',
      ),
      Song(
        title: 'Online Song 3',
        artist: 'Artist 3',
        url: '',
        image: 'assets/images/cover2.jpg',
      ),
      Song(
        title: 'Online Song 4',
        artist: 'Artist 4',
        url: '',
        image: 'assets/images/cover3.jpg',
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SearchField(hintText: 'Search online music...'),
          const SizedBox(height: 25),
          const Text(
            'Trending Online Songs',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 15),
          _HorizontalSongList(songs: dummyOnlineSongs, onSongTap: onSongTap),
          const SizedBox(height: 25),
          const Text(
            'Recently Played',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 15),
          _HorizontalSongList(songs: recentlyPlayed, onSongTap: onSongTap),
        ],
      ),
    );
  }
}

// ================= REUSABLE WIDGETS =================

class _SearchField extends StatelessWidget {
  final String hintText;

  const _SearchField({required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.redAccent),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _HorizontalSongList extends StatelessWidget {
  final List<Song> songs;
  final Future<void> Function(Song) onSongTap;

  const _HorizontalSongList({required this.songs, required this.onSongTap});

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'No songs available',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          return GestureDetector(
            onTap: () => onSongTap(song),
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    child: Image.asset(
                      song.image,
                      width: 140,
                      height: 95,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ================= MINI PLAYER =================
class MiniPlayer extends StatelessWidget {
  final AudioManager audioManager;
  final VoidCallback onTap;

  const MiniPlayer({
    super.key,
    required this.audioManager,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: audioManager,
      builder: (context, _) {
        final song = audioManager.currentSong;
        if (song == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: onTap,
          child: Container(
            color: Colors.grey.shade900,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    song.image,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        song.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        song.artist,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    audioManager.isPlaying
                        ? Icons.pause_circle
                        : Icons.play_circle,
                    color: Colors.redAccent,
                  ),
                  onPressed: () async {
                    await audioManager.togglePlayPause();
                  },
                  iconSize: 40,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, color: Colors.redAccent),
                  onPressed: () async {
                    await audioManager.playNext();
                  },
                  iconSize: 35,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.skip_previous,
                    color: Colors.redAccent,
                  ),
                  onPressed: () async {
                    await audioManager.playPrevious();
                  },
                  iconSize: 35,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ================= WAVE ANIMATION =================

class WaveAnimation extends StatefulWidget {
  final bool isPlaying;
  final Color color;

  const WaveAnimation({
    super.key,
    required this.isPlaying,
    this.color = Colors.redAccent,
  });

  @override
  State<WaveAnimation> createState() => _WaveAnimationState();
}

class _WaveAnimationState extends State<WaveAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      5,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300 + (index * 100)),
      ),
    );

    _animations =
        _controllers.map((controller) {
          return Tween<double>(begin: 0.3, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          );
        }).toList();

    if (widget.isPlaying) {
      _startAnimations();
    }
  }

  @override
  void didUpdateWidget(WaveAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  void _startAnimations() {
    for (var controller in _controllers) {
      controller.repeat(reverse: true);
    }
  }

  void _stopAnimations() {
    for (var controller in _controllers) {
      controller.stop();
      controller.value = 0.3;
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              width: 4,
              height: 40 * _animations[index].value,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          },
        );
      }),
    );
  }
}

// ================= NOW PLAYING SCREEN =================

class NowPlayingScreen extends StatelessWidget {
  final AudioManager audioManager;

  const NowPlayingScreen({super.key, required this.audioManager});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Now Playing',
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: audioManager,
        builder: (context, _) {
          final song = audioManager.currentSong;
          if (song == null) {
            return const Center(
              child: Text(
                'No song playing',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        song.image,
                        width: 300,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      song.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      song.artist,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 50,
                      child: WaveAnimation(
                        isPlaying: audioManager.isPlaying,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Slider(
                      value: audioManager.progress,
                      onChanged: (value) {
                        final newPosition = Duration(
                          milliseconds:
                              (audioManager.totalDuration.inMilliseconds *
                                      value)
                                  .round(),
                        );
                        audioManager.seekTo(newPosition);
                      },
                      activeColor: Colors.redAccent,
                      inactiveColor: Colors.white24,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(audioManager.currentPosition),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _formatDuration(audioManager.totalDuration),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.skip_previous,
                            color: Colors.white,
                            size: 45,
                          ),
                          onPressed: () async {
                            await audioManager.playPrevious();
                          },
                        ),
                        const SizedBox(width: 30),
                        IconButton(
                          icon: Icon(
                            audioManager.isPlaying
                                ? Icons.pause_circle
                                : Icons.play_circle,
                            color: Colors.redAccent,
                            size: 70,
                          ),
                          onPressed: () async {
                            await audioManager.togglePlayPause();
                          },
                        ),
                        const SizedBox(width: 30),
                        IconButton(
                          icon: const Icon(
                            Icons.skip_next,
                            color: Colors.white,
                            size: 45,
                          ),
                          onPressed: () async {
                            await audioManager.playNext();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
