// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, unnecessary_string_interpolations

import 'package:audio_player/controller/audio_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FullScreenPlayer extends StatelessWidget {
  final AudioController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: AlignmentDirectional.topCenter,
              end: Alignment.bottomCenter,
              colors: [
            Colors.deepPurple.shade600,
            Colors.deepPurple.shade200,
          ])),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
              onPressed: (Get.back),
              icon: const Icon(
                Icons.arrow_back_rounded,
                size: 35,
                color: Colors.white,
              )),
          backgroundColor: Colors.transparent,
        ),
        body: Obx(() {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 25, bottom: 20),
                child: Hero(
                  tag: "1",
                  child: CircleAvatar(
                      radius: MediaQuery.sizeOf(context).height / 6,
                      backgroundImage: NetworkImage(
                          "https://api.deezer.com/album/302127/image")),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  controller.currentSongTitle.value,
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 10),
                child: Text(
                  controller.songs[controller.currentIndex.value]['artist']
                      ['name'],
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w400),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child: Slider(
                        min: 0,
                        max: controller.duration.value.inSeconds.toDouble(),
                        value: controller.position.value.inSeconds.toDouble(),
                        onChanged: (value) {
                          final position = Duration(seconds: value.toInt());
                          controller.player.seek(position);
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "${controller.formatDuration(controller.position.value)}",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                            "${controller.formatDuration((controller.duration.value - controller.position.value))}",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              Hero(
                tag: '2',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.skip_previous_rounded,
                        size: 50,
                        color: Colors.deepPurple.shade800,
                      ),
                      onPressed: () {
                        controller.playPreviousSong();
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        controller.isPlaying.value
                            ? Icons.pause_circle_rounded
                            : Icons.play_circle_fill_rounded,
                        size: 50,
                        color: Colors.deepPurple.shade800,
                      ),
                      onPressed: () {
                        if (controller.isPlaying.value) {
                          controller.pauseSong();
                        } else {
                          controller.resumeSong();
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.skip_next_rounded,
                        size: 50,
                        color: Colors.deepPurple.shade800,
                      ),
                      onPressed: () {
                        if (controller.currentIndex.value + 1 <
                            controller.songs.length) {
                          controller
                              .playNextSong(controller.currentIndex.value + 1);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
