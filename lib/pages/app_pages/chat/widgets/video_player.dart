import 'package:cached_video_player/cached_video_player.dart';
import 'package:chatapp/utils/colors.dart';
import 'package:flutter/material.dart';

class VideoPlayer extends StatefulWidget {
  final String message;
  const VideoPlayer({super.key, required this.message});

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  late CachedVideoPlayerController _controller;
  bool isPlaying = false;

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = CachedVideoPlayerController.network(widget.message)
      ..initialize().then((value) {
        _controller.setVolume(1);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(7.5)),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Stack(
          children: [
            CachedVideoPlayer(_controller),
            Align(
              alignment: Alignment.center,
              child: IconButton(
                onPressed: () {
                  isPlaying ? _controller.pause() : _controller.play();
                  isPlaying = !isPlaying;
                  setState(() {});
                },
                icon: isPlaying
                    ? Icon(
                        Icons.pause_rounded,
                        color: ColorPallete.white,
                      )
                    : Icon(Icons.play_arrow_rounded, color: ColorPallete.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
