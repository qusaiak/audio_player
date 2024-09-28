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
                  tag: controller.currentSong.value!.albumArtUrl,
                  child: CircleAvatar(
                      radius: MediaQuery.sizeOf(context).height / 6,
                      backgroundImage: NetworkImage(
                          controller.currentSong.value!.albumArtUrl)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  controller.currentSong.value!.title,
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8,bottom: 10),
                child: Text(
                  controller.currentSong.value!.artist,
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w400),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 25,horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("${controller.formatDuration(controller.position.value)}",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                    Slider(
                        min: 0,
                        max: controller.duration.value.inSeconds.toDouble(),
                        value: controller.position.value.inSeconds.toDouble(),
                        onChanged: (value) {
                          final position = Duration(seconds: value.toInt());
                          controller.player.seek(position);
                        }),
                    Text(
                        "${controller.formatDuration((controller.duration.value - controller.position.value))}",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Hero(
                tag: controller.currentSong.value!.title,
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
                        if (controller.currentIndex.value - 1 >= 0) {
                          controller.playPreviousSong(
                              controller.currentIndex.value - 1);
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        controller.isPlaying.value
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 45,
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
