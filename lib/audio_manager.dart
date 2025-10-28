import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'song.dart';

class AudioManager extends ChangeNotifier {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal() {
    _setupListeners();
  }

  final AudioPlayer _player = AudioPlayer();
  List<Song> _playlist = [];
  int _currentIndex = 0;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  final List<Song> _recentlyPlayed = [];

  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _completeSubscription;
  StreamSubscription<PlayerState>? _stateSubscription;

  // Getters
  bool get isPlaying => _player.state == PlayerState.playing;
  Song? get currentSong =>
      _playlist.isNotEmpty ? _playlist[_currentIndex] : null;
  List<Song> get recentlyPlayed => List.unmodifiable(_recentlyPlayed);
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  double get progress => _totalDuration.inMilliseconds > 0
      ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
      : 0.0;
  List<Song> get playlist => _playlist;

  void initialize(List<Song> songs) {
    _playlist = songs;
  }

  void _setupListeners() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _completeSubscription?.cancel();
    _stateSubscription?.cancel();

    _positionSubscription = _player.onPositionChanged.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });

    _durationSubscription = _player.onDurationChanged.listen((duration) {
      _totalDuration = duration;
      notifyListeners();
    });

    _completeSubscription = _player.onPlayerComplete.listen((_) {
      playNext();
    });

    _stateSubscription = _player.onPlayerStateChanged.listen((state) {
      notifyListeners(); // Auto-update isPlaying in UI
    });
  }

  Future<void> togglePlayPause() async {
    if (_playlist.isEmpty) return;

    final currentSongObj = currentSong ?? _playlist[0];

    if (_player.state == PlayerState.playing) {
      await _player.pause();
    } else if (_player.state == PlayerState.paused) {
      await _player.resume();
    } else {
      // stopped or not yet played
      await _player.stop();
      await _player.play(AssetSource(currentSongObj.url));
    }

    notifyListeners();
  }

  Future<void> playSelected(int index) async {
    if (_playlist.isEmpty) return;
    _currentIndex = index;
    _addToRecentlyPlayed(_playlist[_currentIndex]);
    await _player.stop();
    await _player.play(AssetSource(_playlist[_currentIndex].url));
  }

  Future<void> playNext() async {
    if (_playlist.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % _playlist.length;
    _addToRecentlyPlayed(_playlist[_currentIndex]);
    await _player.stop();
    await _player.play(AssetSource(_playlist[_currentIndex].url));
  }

  Future<void> playPrevious() async {
    if (_playlist.isEmpty) return;
    _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
    _addToRecentlyPlayed(_playlist[_currentIndex]);
    await _player.stop();
    await _player.play(AssetSource(_playlist[_currentIndex].url));
  }

  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  void _addToRecentlyPlayed(Song song) {
    _recentlyPlayed.removeWhere((s) => s.url == song.url);
    _recentlyPlayed.insert(0, song);
    if (_recentlyPlayed.length > 10) _recentlyPlayed.removeLast();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _completeSubscription?.cancel();
    _stateSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }
}
