import 'package:flutter/material.dart';

class DeviceTab extends StatelessWidget {
  final List<Map<String, String>> recentlyPlayed = [
    {'title': 'Heat Waves', 'artist': 'Glass Animals'},
    {'title': 'Blinding Lights', 'artist': 'The Weeknd'},
    {'title': 'Levitating', 'artist': 'Dua Lipa'},
    {'title': 'Stay', 'artist': 'The Kid LAROI'},
  ];

  final List<Map<String, String>> deviceSongs = [
    {'title': 'Peaches', 'artist': 'Justin Bieber'},
    {'title': 'Industry Baby', 'artist': 'Lil Nas X'},
    {'title': 'Save Your Tears', 'artist': 'The Weeknd'},
    {'title': 'Good 4 U', 'artist': 'Olivia Rodrigo'},
    {'title': 'Bad Habits', 'artist': 'Ed Sheeran'},
    {'title': 'Shivers', 'artist': 'Ed Sheeran'},
    {'title': 'Mood', 'artist': '24kGoldn'},
    {'title': 'Watermelon Sugar', 'artist': 'Harry Styles'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Recently Played",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recentlyPlayed.length,
                itemBuilder: (context, index) {
                  final song = recentlyPlayed[index];
                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.music_note, size: 50, color: Colors.white70),
                        const SizedBox(height: 8),
                        Text(song['title']!, style: TextStyle(color: Colors.white, fontSize: 14), textAlign: TextAlign.center),
                        Text(song['artist']!, style: TextStyle(color: Colors.white54, fontSize: 12), textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Device Songs",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Column(
              children: deviceSongs.map((song) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.music_video, color: Colors.white70),
                    title: Text(song['title']!, style: TextStyle(color: Colors.white)),
                    subtitle: Text(song['artist']!, style: TextStyle(color: Colors.white54)),
                    trailing: Icon(Icons.more_vert, color: Colors.white54),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
