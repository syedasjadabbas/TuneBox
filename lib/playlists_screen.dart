import 'package:flutter/material.dart';
import 'song.dart';

class PlaylistsScreen extends StatefulWidget {
  final List<Song> allSongs;

  const PlaylistsScreen({Key? key, required this.allSongs}) : super(key: key);

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  static final List<Playlist> _persistentPlaylists = [];

  void _createPlaylist() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey.shade900,
            title: const Text(
              'Create Playlist',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter playlist name',
                hintStyle: const TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.redAccent),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.redAccent, width: 2),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    setState(() {
                      _persistentPlaylists.add(
                        Playlist(name: nameController.text, songs: []),
                      );
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'Create',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
    );
  }

  void _openPlaylist(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => PlaylistDetailScreen(
              playlist: _persistentPlaylists[index],
              allSongs: widget.allSongs,
              onUpdate: () => setState(() {}),
            ),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  void _renamePlaylist(int index) {
    final renameController = TextEditingController(
      text: _persistentPlaylists[index].name,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey.shade900,
            title: const Text(
              'Rename Playlist',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: TextField(
              controller: renameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter new playlist name',
                hintStyle: const TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.redAccent),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.redAccent, width: 2),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (renameController.text.isNotEmpty) {
                    setState(() {
                      _persistentPlaylists[index].name = renameController.text;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Playlist renamed'),
                        backgroundColor: Colors.redAccent,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Rename',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
    );
  }

  void _deletePlaylist(int index) {
    setState(() {
      _persistentPlaylists.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Playlist deleted'),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Playlists',
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
      body:
          _persistentPlaylists.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.library_music, size: 80, color: Colors.white24),
                    const SizedBox(height: 16),
                    const Text(
                      'No playlists yet',
                      style: TextStyle(color: Colors.white54, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create a playlist to get started',
                      style: TextStyle(color: Colors.white38, fontSize: 14),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _persistentPlaylists.length,
                itemBuilder: (context, index) {
                  final playlist = _persistentPlaylists[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade800),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.library_music,
                            color: Colors.redAccent,
                            size: 28,
                          ),
                        ),
                      ),
                      title: Text(
                        playlist.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        '${playlist.songs.length} songs',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                      trailing: PopupMenuButton(
                        color: Colors.grey.shade900,
                        itemBuilder:
                            (context) => [
                              PopupMenuItem(
                                child: const Text(
                                  'Rename',
                                  style: TextStyle(color: Colors.white),
                                ),
                                onTap: () => _renamePlaylist(index),
                              ),
                              PopupMenuItem(
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                                onTap: () => _deletePlaylist(index),
                              ),
                            ],
                      ),
                      onTap: () => _openPlaylist(index),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: _createPlaylist,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// ================= PLAYLIST DETAIL SCREEN =================

class PlaylistDetailScreen extends StatefulWidget {
  final Playlist playlist;
  final List<Song> allSongs;
  final VoidCallback onUpdate;

  const PlaylistDetailScreen({
    Key? key,
    required this.playlist,
    required this.allSongs,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  late List<Song> playlistSongs;

  @override
  void initState() {
    super.initState();
    playlistSongs = List.from(widget.playlist.songs);
  }

  void _addSongsToPlaylist() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey.shade900,
            title: const Text(
              'Add Songs',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.allSongs.length,
                itemBuilder: (context, index) {
                  final song = widget.allSongs[index];
                  final isAdded = playlistSongs.contains(song);

                  return CheckboxListTile(
                    activeColor: Colors.redAccent,
                    checkColor: Colors.white,
                    title: Text(
                      song.title,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      song.artist,
                      style: const TextStyle(color: Colors.white54),
                    ),
                    value: isAdded,
                    onChanged: (value) {
                      setState(() {
                        if (value ?? false) {
                          playlistSongs.add(song);
                          widget.playlist.songs.add(song);
                        } else {
                          playlistSongs.remove(song);
                          widget.playlist.songs.remove(song);
                        }
                      });
                      widget.onUpdate();
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Done',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
    );
  }

  void _removeSongFromPlaylist(int index) {
    setState(() {
      widget.playlist.songs.removeAt(index);
      playlistSongs.removeAt(index);
    });
    widget.onUpdate();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Song removed from playlist'),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.playlist.name,
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
      body:
          playlistSongs.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.music_note, size: 80, color: Colors.white24),
                    const SizedBox(height: 16),
                    const Text(
                      'No songs in this playlist',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: playlistSongs.length,
                itemBuilder: (context, index) {
                  final song = playlistSongs[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade800),
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
                            song.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade800,
                                child: const Icon(
                                  Icons.music_note,
                                  color: Colors.redAccent,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      title: Text(
                        song.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        song.artist,
                        style: const TextStyle(color: Colors.white54),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => _removeSongFromPlaylist(index),
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: _addSongsToPlaylist,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomSheet:
          playlistSongs.isEmpty
              ? null
              : Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addSongsToPlaylist,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Add Songs',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
    );
  }
}

// ================= PLAYLIST MODEL =================

class Playlist {
  String name;
  final List<Song> songs;

  Playlist({required this.name, required this.songs});
}
