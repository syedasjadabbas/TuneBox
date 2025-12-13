import 'package:get/get.dart';
import 'package:music_player/model/song_item.dart';

class FavoritesController extends GetxController {
  final RxList<UnifiedSong> favorites = <UnifiedSong>[].obs;

  bool isFavorite(String idKey) =>
      favorites.any((element) => element.idKey == idKey);

  void toggleFavorite(UnifiedSong song) {
    final existingIndex =
        favorites.indexWhere((element) => element.idKey == song.idKey);
    if (existingIndex != -1) {
      favorites.removeAt(existingIndex);
    } else {
      favorites.add(song);
    }
  }
}
