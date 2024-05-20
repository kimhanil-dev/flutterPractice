import 'dart:io';

import 'package:acter_project/screen/service/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player_win/video_player_win.dart' as video;

/// set(image, posX, posY)
class UIVideoPlayer extends UI {
  UIVideoPlayer({super.key});

  @override
  bool get isForward => false;

  @override
  State<UIVideoPlayer> createState() => UIVideoPlayerState();
}

class UIVideoPlayerState extends State<UIVideoPlayer> with TickerProviderStateMixin {

  late video.WinVideoPlayerController videoController;

  @override
  void initState() {
    super.initState();

    // add command
    // from, to , time/ms

    videoController = video.WinVideoPlayerController.file(File('C:\\test.mp4'));
    videoController.initialize().then((value){
      setState(() {
        videoController.play();
      });
    });
  }

  void invisible() {
    if(videoController.value.isInitialized) {
      videoController.pause();
      videoController.dispose();
    }
  }


  @override
  Widget build(BuildContext context) {
    return video.WinVideoPlayer(videoController);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
