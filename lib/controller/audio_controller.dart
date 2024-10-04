// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

class AudioController extends GetxController {
  List<AudioSource> songsList = [];
  var songs = [];
  var filteredSongs = [];
  var isPlaying = false.obs;
  final player = AudioPlayer();
  var currentIndex = 0.obs;
  var currentSongTitle = ''.obs;
  var isLoading = true.obs;
  var play = false.obs;
  var duration = Duration.zero.obs;
  var position = Duration.zero.obs;
  var title = 't'.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    getSongsFromAPI();
    await listenForCompletion();
    listenForSongChanges();
    listenForPlaybackState();
    // fetchSongsFromJson();
  }

  // Future<void> fetchSongsFromJson() async {
  //   try {
  //     isLoading(true);
  //     await Future.delayed(const Duration(seconds: 3));
  //     final String response = await rootBundle.loadString('assets/songs.json');
  //     final List<dynamic> jsonData = jsonDecode(response);
  //     songs.value =
  //         jsonData.map((songJson) => SongModel.fromJson(songJson)).toList();
  //     filteredSongs.value = songs;
  //   } catch (e) {
  //     print('Error loading songs: $e');
  //   } finally {
  //     isLoading(false);
  //   }
  //   update();
  // }

  void filterSongs(String search) async {
    isLoading(true);
    if (search.isEmpty) {
      filteredSongs = songs;
    } else {
      filteredSongs = songs.where((song) {
        return song['title'].toLowerCase().contains(search.toLowerCase());
      }).toList();
    }
    isLoading(false);
    update();
  }

  Future<void> playSong(int index) async {
    currentIndex.value = index;
    play.value = true;
    update();
    try {
      await player.setAudioSource(
          initialIndex: index, ConcatenatingAudioSource(children: songsList));
      player.play();
      update();
    } catch (e) {
      print("Error playing song: $e");
    } finally {
      isPlaying(true);
      update();
    }
  }

  void pauseSong() {
    player.pause();
    isPlaying.value = false;
    update();
  }

  void resumeSong() {
    player.play();
    isPlaying.value = true;
    update();
  }

  void stopSong() {
    player.stop();
    isPlaying.value = false;
    update();
  }

  Future<void> listenForCompletion() async {
    player.processingStateStream.listen((state) async {
      if (state == ProcessingState.completed) {
        await Future.delayed(const Duration(seconds: 3));
        await playNextSong(currentIndex.value + 1);
        await Future.delayed(const Duration(seconds: 3));
        update();
      }
    });
    player.durationStream.listen((newDuration) {
      if (newDuration != null) {
        duration.value = newDuration;
        update();
      }
    });
    player.positionStream.listen((newPosition) {
      position.value = newPosition;
      update();
    });
  }

  Future<void> playNextSong(int nextIndex) async {
    await player.seekToNext();
    await player.play();
    update();
  }

  Future<void> playPreviousSong() async {
    final currentIndex = player.currentIndex;
    if (currentIndex != null && currentIndex > 0) {
      await player.seekToPrevious();
      if (!player.playing) {
        await player.play();
      }
      update();
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours.remainder(60));
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  Future<void> getSongsFromAPI() async {
    try {
      isLoading(true);
      await Future.delayed(const Duration(seconds: 3));
      final response = await http
          .get(Uri.parse('https://api.deezer.com/album/302127/tracks'));
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        songs = jsonData['data'];
        filteredSongs = songs;
        songsList = songs.map((songUrl) {
          return AudioSource.uri(
            Uri.parse(songUrl['preview']),
            tag: MediaItem(
              id: songUrl['preview'],
              title: songUrl['title'],
              artist: songUrl['artist']['name'],
              artUri: Uri.parse("https://api.deezer.com/album/302127/image"),
              duration: duration.value,
            ),
          );
        }).toList();
        update();
      } else {
        print('Failed to load songs: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching songs from API: $e');
    } finally {
      isLoading(false);
    }
    update();
  }

  void getCurrentSongTitle(int? index) {
    if (index != null && index < songsList.length) {
      final currentSource = songsList[index];
      if (currentSource is UriAudioSource) {
        final mediaItem = currentSource.tag as MediaItem;
        currentSongTitle.value = mediaItem.title;
      }
    } else {
      currentSongTitle.value = '';
    }
  }

  void listenForSongChanges() {
    player.currentIndexStream.listen((index) {
      getCurrentSongTitle(index);
    });
  }

  void listenForPlaybackState() {
    player.playingStream.listen((isPlayingNow) {
      isPlaying.value = isPlayingNow;
    });
  }
}
