// ignore_for_file: prefer_const_constructors

import 'package:audio_player/controller/audio_controller.dart';
import 'package:audio_player/view/fullscreen_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  final AudioController controller = Get.put(AudioController());
  final TextEditingController search = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  HomePage({super.key});
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
            title: const Text(
              'Audio Player',
              style: TextStyle(
                fontSize: 25,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
          ),
          bottomNavigationBar: Obx(() {
            if (!controller.play.value) {
              return SizedBox.shrink();
            }
            return GestureDetector(
              onTap: () {
                Get.to(FullScreenPlayer());
              },
              child: Container(
                margin: const EdgeInsets.all(8.0),
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20)),
                  color: Colors.deepPurple.shade500,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Hero(
                      tag: "1",
                      child: LayoutBuilder(builder: (context, constraints) {
                        return Container(
                          width: 50,
                          margin: EdgeInsets.only(left: 10, top: 5, bottom: 5),
                          height: constraints.maxHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(11),
                              bottomLeft: Radius.circular(11),
                              topRight: Radius.circular(11),
                              bottomRight: Radius.circular(11),
                            ),
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: NetworkImage(
                                  "https://api.deezer.com/album/302127/image"),
                            ),
                          ),
                        );
                      }),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          controller.title.value,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Hero(
                      tag: '2',
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.skip_previous_rounded,
                              size: 30,
                              color: Colors.white,
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
                              size: 30,
                              color: Colors.white,
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
                              size: 30,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              if (controller.currentIndex.value + 1 <
                                  controller.songs.length) {
                                controller.playNextSong(
                                    controller.currentIndex.value + 1);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: TextFormField(
                  focusNode: FocusNode(
                    onKeyEvent: (node, event) {
                      searchFocusNode.unfocus();
                      return KeyEventResult.handled;
                    },
                  ),
                  onChanged: (value) async {
                    controller.isLoading.value = true;
                    await Future.delayed(const Duration(seconds: 2));
                    controller.filterSongs(search.text);
                    controller.isLoading.value = false;
                  },
                  textAlign: TextAlign.start,
                  controller: search,
                  decoration: InputDecoration(
                    prefixIcon: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.search,
                          size: 23,
                          color: Colors.deepPurple.shade800,
                        )),
                    suffixIcon: IconButton(
                        onPressed: () {
                          controller.filterSongs('');
                          search.text = '';
                        },
                        icon: Icon(
                          Icons.cancel_outlined,
                          size: 23,
                          color: Colors.deepPurple.shade800,
                        )),
                    isDense: true,
                    fillColor: Colors.white,
                    filled: true,
                    hintText: "Search",
                    hintStyle: TextStyle(color: Colors.deepPurple.shade200),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: Colors.deepPurple.shade200, width: 1.5)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: Colors.deepPurple.shade200, width: 1.5)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: Colors.deepPurple.shade200, width: 1.5)),
                  ),
                  keyboardType: TextInputType.name,
                ),
              ),
              Expanded(child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                      child: CircularProgressIndicator(
                    color: Colors.white,
                  ));
                } else if (controller.filteredSongs.isEmpty) {
                  if (search.text != '') {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.music_off_rounded,
                            size: 50,
                            color: Colors.white,
                          ),
                          Text(
                            "Song not found",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  } else if (controller.isLoading.value) {
                    return Center(
                        child: CircularProgressIndicator(
                      color: Colors.white,
                    ));
                  }
                }
                return ListView.builder(
                  itemCount: controller.filteredSongs.length,
                  itemExtent: MediaQuery.of(context).size.height / 10,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 12),
                      child: Card(
                        color: Colors.deepPurple.shade100,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return Container(
                                    margin: EdgeInsets.all(5),
                                    height: constraints.maxHeight,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(11),
                                        bottomLeft: Radius.circular(11),
                                        topRight: Radius.circular(11),
                                        bottomRight: Radius.circular(11),
                                      ),
                                      image: DecorationImage(
                                        fit: BoxFit.fill,
                                        image: NetworkImage(
                                            "https://api.deezer.com/album/302127/image"),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: ListTile(
                                title: Text(
                                    controller.filteredSongs[index]['title'],
                                    style: TextStyle(
                                        color: Colors.deepPurple.shade600,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                subtitle: Text(
                                  controller.filteredSongs[index]['artist']
                                      ['name'],
                                  style: TextStyle(
                                      color: Colors.deepPurple.shade400,
                                      fontWeight: FontWeight.w400),
                                ),
                                trailing: IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.music_note_rounded,
                                      size: 32,
                                      color: Colors.deepPurple.shade600,
                                    )),
                                onTap: () {
                                  controller.playSong(index);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              })),
            ],
          )),
    );
  }
}
