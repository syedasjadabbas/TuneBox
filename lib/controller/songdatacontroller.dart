import 'package:get/get.dart';
import 'package:music_player/controller/songPlayerController.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class SongDataController extends GetxController {
  final audioQuery = OnAudioQuery();
  Songplayercontroller songplayercontroller = Get.put(Songplayercontroller());

  RxList<SongModel> localSongList = <SongModel>[].obs;
  RxBool isDeviceSong = false.obs;
  RxInt currentSongPlayingIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    initLocalSongs();
  }

  Future<void> initLocalSongs() async {
    // Request permissions before querying songs to avoid runtime crash
    try {
      // OnAudioQuery has its own permission helper
      if (!await audioQuery.permissionsStatus()) {
        final granted = await audioQuery.permissionsRequest();
        if (!granted) {
          return;
        }
      }

      // Extra safety: request modern media permissions (Android 13+) and legacy storage
      await Permission.audio.request();
      await Permission.photos.request();
      await Permission.videos.request();
      await Permission.storage.request();

      await getLocalSongs();
    } catch (e) {
      print('Error requesting media permission: $e');
    }
  }

  Future<void> getLocalSongs() async {
    localSongList.value = await audioQuery.querySongs(
      ignoreCase: true,
      orderType: OrderType.ASC_OR_SMALLER,
      sortType: null,
      uriType: UriType.EXTERNAL,
    );
  }

  void findCurrentPlayingSongId(int songId) {
    var index = 0;

    localSongList.forEach((e) {
      if (e.id == songId) {
        currentSongPlayingIndex.value = index;
      }
      index++;
    });
    print(songId);
    print(currentSongPlayingIndex);
  }

  void playNextSong() {
    currentSongPlayingIndex.value = currentSongPlayingIndex.value + 1;
    SongModel nextSong = localSongList[currentSongPlayingIndex.value];
    songplayercontroller.playLocalAudio(nextSong);
  }

  void playPreviousSong() {
    currentSongPlayingIndex.value = currentSongPlayingIndex.value - 1;
    SongModel nextSong = localSongList[currentSongPlayingIndex.value];
    songplayercontroller.playLocalAudio(nextSong);
  }
}
