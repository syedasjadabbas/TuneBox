import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/model/mySongModel.dart';
import 'package:music_player/model/song_item.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Songplayercontroller extends GetxController {
  final player = AudioPlayer();
  RxBool isPlaying = false.obs;
  var currentSongTitle = ''.obs;
  RxString currentArtist = ''.obs;
  RxString currentTime = "0:00".obs;
  RxString totalTime = "0:00".obs;
  RxBool isLoop = false.obs;
  RxBool isShuffled = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Ensure the player is properly initialized if needed
    player.playbackEventStream.listen((event) {
      // Update currentTime and totalTime when the playback event changes
      currentTime.value = formatDuration(player.position);
      totalTime.value = formatDuration(player.duration ?? Duration.zero);
    });
  }

  void playLocalAudio(SongModel song) async {
    try {
      await player.setAudioSource(AudioSource.uri(Uri.parse(song.data)));
      player.play();
      isPlaying.value = true;
       currentSongTitle.value = song.title;
       currentArtist.value = song.artist ?? "";
      updatePosition();
    } catch (e) {
      print("Error playing local audio: $e");
    }
  }

  void playCloudAudio(MySongModel song) async {
    try {
      await player.setAudioSource(AudioSource.uri(Uri.parse(song.data)));
      player.play();
      isPlaying.value = true;
      currentSongTitle.value = song.title;
      currentArtist.value = "Cloud track";
      updatePosition();
    } catch (e) {
      print("Error playing cloud audio: $e");
    }
  }

  Future<void> playUnifiedSong(UnifiedSong song) async {
    try {
      await player.setAudioSource(AudioSource.uri(Uri.parse(song.data)));
      player.play();
      isPlaying.value = true;
      currentSongTitle.value = song.title;
      currentArtist.value = song.artist ?? "";
      updatePosition();
    } catch (e) {
      print("Error playing unified audio: $e");
    }
  }

  void updatePosition() {
    player.durationStream.listen((d) {
      totalTime.value = d != null ? formatDuration(d) : "0:00";
    });
    player.positionStream.listen((p) {
      currentTime.value = formatDuration(p);
    });
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void updateSongTitle(String title) {
    currentSongTitle.value = title;
  }

  void playSong(String title) {
    currentSongTitle.value = title;
    isPlaying.value = true;
  }

  void pausePlaying() async {
    isPlaying.value = false;
    await player.pause();
  }

  void playRandomSong() async {
    isShuffled.value = !isShuffled.value;
    await player.setShuffleModeEnabled(isShuffled.value);
  }

  void setLoopSong() async {
    isLoop.value = !isLoop.value;
    await player.setLoopMode(isLoop.value ? LoopMode.one : LoopMode.off);
  }

  void resumePlaying() async {
    isPlaying.value = true;
    await player.play();
  }

  void changeDurationToSecond(int seconds) {
    var duration = Duration(seconds: seconds);
    player.seek(duration);
  }
}
