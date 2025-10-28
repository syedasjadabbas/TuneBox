import 'package:flutter/material.dart';
import 'audio_manager.dart';
import 'song.dart';

// Import only NowPlayingScreen from main
import 'main.dart' show NowPlayingScreen;

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final AudioManager _audioManager = AudioManager();

  // TODO: Replace with actual data from AudioManager playlist
  final List<Map<String, String>> topSongs = [
    {'title': 'Shape of You', 'artist': 'Ed Sheeran', 'image': 'assets/images/song1.jpg'},
    {'title': 'tv off', 'artist': 'Kendrick Lamar', 'image': 'assets/images/song2.jpg'},
    {'title': 'Believer', 'artist': 'Imagine Dragons', 'image': 'assets/images/song3.jpg'},
    {'title': 'Happy Nation', 'artist': 'Ace of Base', 'image': 'assets/images/song4.jpg'},
    {'title': 'Perfect', 'artist': 'Ed Sheeran', 'image': 'assets/images/song5.jpg'},
    {'title': 'Star Boys', 'artist': 'Weeknd', 'image': 'assets/images/song6.jpg'},
  ];

  final List<Map<String, String>> themesFolders = [
    {'name': 'Chill Vibes', 'image': 'assets/images/cover1.jpg'},
    {'name': 'Workout', 'image': 'assets/images/cover2.jpg'},
    {'name': 'Romance', 'image': 'assets/images/song1.jpg'},
    {'name': 'Road Trip', 'image': 'assets/images/song2.jpg'},
    {'name': 'Study Mode', 'image': 'assets/images/cover4.jpg'},
    {'name': 'Party Hits', 'image': 'assets/images/song3.jpg'},
    {'name': 'Late Night', 'image': 'assets/images/cover5.jpg'},
    {'name': 'Morning Vibes', 'image': 'assets/images/song4.jpg'},
    {'name': 'Sad Songs', 'image': 'assets/images/song5.jpg'},
    {'name': 'Feel Good', 'image': 'assets/images/song6.jpg'},
  ];

  final List<Map<String, String>> singersFolders = [
    {'name': 'Arijit Singh', 'image': 'assets/images/cover1.jpg'},
    {'name': 'Weeknd', 'image': 'assets/images/song6.jpg'},
    {'name': 'Taylor Swift', 'image': 'assets/images/cover2.jpg'},
    {'name': 'Atif Aslam', 'image': 'assets/images/song1.jpg'},
    {'name': 'Billie Eilish', 'image': 'assets/images/cover4.jpg'},
    {'name': 'Ed Sheeran', 'image': 'assets/images/song5.jpg'},
    {'name': 'Dua Lipa', 'image': 'assets/images/song3.jpg'},
    {'name': 'Justin Bieber', 'image': 'assets/images/song4.jpg'},
    {'name': 'Kendrick Lamar', 'image': 'assets/images/song2.jpg'},
    {'name': 'Drake', 'image': 'assets/images/cover5.jpg'},
    {'name': 'Ariana Grande', 'image': 'assets/images/song7.jpg'},
    {'name': 'Post Malone', 'image': 'assets/images/song8.jpg'},
  ];

  Future<void> _playSong(String title, String artist, String image) async {
    print('Playing: $title by $artist');

    if (_audioManager.currentSong != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NowPlayingScreen(audioManager: _audioManager),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please play a song from Home first'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _openFolder(String folderName, String folderType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FolderSongsScreen(
          folderName: folderName,
          folderType: folderType,
          audioManager: _audioManager,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Library',
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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // TOP LISTENED SONGS SECTION
            _buildSectionHeader('Top Listened Songs of the Month'),
            const SizedBox(height: 12),
            _buildTopSongsSection(),

            const SizedBox(height: 32),

            // BY THEMES SECTION
            _buildSectionHeader('By Themes'),
            const SizedBox(height: 12),
            _buildFoldersGrid(themesFolders, 'theme'),

            const SizedBox(height: 32),

            // BY SINGERS SECTION
            _buildSectionHeader('By Singers'),
            const SizedBox(height: 12),
            _buildFoldersGrid(singersFolders, 'singer'),

            const SizedBox(height: 100), // Bottom padding for mini player
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.redAccent,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTopSongsSection() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: topSongs.length,
        itemBuilder: (context, index) {
          final song = topSongs[index];
          return GestureDetector(
            onTap: () => _playSong(
              song['title']!,
              song['artist']!,
              song['image']!,
            ),
            child: Container(
              width: 150,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        song['image']!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.music_note,
                            size: 60,
                            color: Colors.white38,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    song['title']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    song['artist']!,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFoldersGrid(List<Map<String, String>> folders, String folderType) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemCount: folders.length,
        itemBuilder: (context, index) {
          final folder = folders[index];
          return GestureDetector(
            onTap: () => _openFolder(folder['name']!, folderType),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        folder['image']!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            folderType == 'theme' ? Icons.folder : Icons.person,
                            size: 50,
                            color: Colors.redAccent,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      folder['name']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

// ================= FOLDER SONGS SCREEN =================

class FolderSongsScreen extends StatefulWidget {
  final String folderName;
  final String folderType;
  final AudioManager audioManager;

  const FolderSongsScreen({
    Key? key,
    required this.folderName,
    required this.folderType,
    required this.audioManager,
  }) : super(key: key);

  @override
  State<FolderSongsScreen> createState() => _FolderSongsScreenState();
}

class _FolderSongsScreenState extends State<FolderSongsScreen> {
  String _searchQuery = '';

  // TODO: Replace with actual filtered songs from on_audio_query
  final List<Map<String, String>> dummySongs = [
    {'title': 'Song 1', 'artist': 'Artist 1', 'image': 'assets/images/song1.jpg'},
    {'title': 'Song 2', 'artist': 'Artist 2', 'image': 'assets/images/song2.jpg'},
    {'title': 'Song 3', 'artist': 'Artist 3', 'image': 'assets/images/song3.jpg'},
    {'title': 'Song 4', 'artist': 'Artist 4', 'image': 'assets/images/song4.jpg'},
    {'title': 'Song 5', 'artist': 'Artist 5', 'image': 'assets/images/song5.jpg'},
    {'title': 'Song 6', 'artist': 'Artist 6', 'image': 'assets/images/song6.jpg'},
    {'title': 'Song 7', 'artist': 'Artist 7', 'image': 'assets/images/song7.jpg'},
    {'title': 'Song 8', 'artist': 'Artist 8', 'image': 'assets/images/song8.jpg'},
  ];

  List<Map<String, String>> get filteredSongs {
    if (_searchQuery.isEmpty) return dummySongs;
    return dummySongs
        .where((song) =>
    song['title']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        song['artist']!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> _playSong(String title, String artist) async {
    print('Playing: $title by $artist');

    if (widget.audioManager.currentSong != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NowPlayingScreen(audioManager: widget.audioManager),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please play a song from Home first'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.folderName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.redAccent, Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.redAccent),
                hintText: 'Search songs...',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Songs List
          Expanded(
            child: filteredSongs.isEmpty
                ? const Center(
              child: Text(
                'No songs found',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredSongs.length,
              itemBuilder: (context, index) {
                final song = filteredSongs[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          song['image']!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.music_note,
                              color: Colors.redAccent,
                            );
                          },
                        ),
                      ),
                    ),
                    title: Text(
                      song['title']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      song['artist']!,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.play_circle_filled,
                        color: Colors.redAccent,
                        size: 36,
                      ),
                      onPressed: () => _playSong(
                        song['title']!,
                        song['artist']!,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}