// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:audio_player/model/song_model.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class AudioController extends GetxController {
  var songs = <SongModel>[].obs;
  var filteredSongs = <SongModel>[].obs;
  var isPlaying = false.obs;
  var currentSong = Rxn<SongModel>();
  final player = AudioPlayer();
  var currentIndex = 0.obs;
  var isLoading = true.obs;
  var duration = Duration.zero.obs;
  var position = Duration.zero.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSongsFromJson();
    listenForCompletion();
  }

  Future<void> fetchSongsFromJson() async {
    try {
      isLoading(true);
      await Future.delayed(const Duration(seconds: 3));
      final String response = await rootBundle.loadString('assets/songs.json');
      final List<dynamic> jsonData = jsonDecode(response);
      songs.value =
          jsonData.map((songJson) => SongModel.fromJson(songJson)).toList();
      filteredSongs.value = songs;
    } catch (e) {
      print('Error loading songs: $e');
    } finally {
      isLoading(false);
    }
    update();
  }

  void filterSongs(String search) async {
    isLoading(true);
    if (search.isEmpty) {
      filteredSongs.value = songs;
    } else {
      filteredSongs.value = songs.where((song) {
        return song.title.toLowerCase().contains(search.toLowerCase());
      }).toList();
    }
    isLoading(false);
    update();
  }

  Future<void> playSong(int index) async {
    currentSong.value = songs[index];
    currentIndex.value = index;
    try {
      await player.setUrl(songs[index].streamingUrl);
      player.play();
      isPlaying(true);
    } catch (e) {
      print("Error playing song: $e");
    }
  }

  void pauseSong() {
    player.pause();
    isPlaying.value = false;
  }

  void resumeSong() {
    player.play();
    isPlaying.value = true;
  }

  void stopSong() {
    player.stop();
    isPlaying.value = false;
  }

  void listenForCompletion() {
    player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        playNextSong(currentIndex.value + 1);
      }
    });
    player.durationStream.listen((newDuration) {
      duration.value = newDuration!;
      update();
    });
    player.positionStream.listen((newPosition) {
      position.value = newPosition;

      update();
    });
  }

  void playNextSong(int nextIndex) {
    if (nextIndex < songs.length) {
      playSong(nextIndex);
    } else {
      stopSong();
    }
  }

  void playPreviousSong(int previousIndex) {
    if (previousIndex >= 0) {
      playSong(previousIndex);
    } else {
      stopSong();
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours.remainder(60));
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }
}
