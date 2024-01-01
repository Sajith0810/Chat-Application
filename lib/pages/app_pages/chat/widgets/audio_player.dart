import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioFile;
  const AudioPlayerWidget({super.key, required this.audioFile});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  double maxLength = 0;
  double currentValue = 0;

  @override
  void dispose() {
    super.dispose();
    audioPlayer.dispose();
  }

  void playAudioFile() async {
    if (!isPlaying) {
      await audioPlayer.play(UrlSource(widget.audioFile));
      audioPlayer.onPositionChanged.listen((event) {
        currentValue = event.inSeconds.toDouble();
      });
      audioPlayer.onDurationChanged.listen((event) {
        maxLength = event.inSeconds.toDouble();
      });
      audioPlayer.onPlayerComplete.listen((event) {
        setState(() => isPlaying = false);
      });
      setState(() => isPlaying = true);
    } else {
      await audioPlayer.pause();
      setState(() => isPlaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              playAudioFile();
            },
            icon: isPlaying
                ? const Icon(Icons.pause_rounded)
                : const Icon(Icons.play_arrow_rounded),
          ),
          Expanded(
            child: Slider(
              onChanged: (value) {
                audioPlayer.seek(Duration(seconds: value.toInt()));
              },
              min: 0,
              max: maxLength,
              value: currentValue,
            ),
          )
        ],
      ),
    );
  }
}
