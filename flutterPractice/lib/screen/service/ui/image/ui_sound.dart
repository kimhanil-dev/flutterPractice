import 'dart:io';

import 'package:acter_project/screen/service/data_manager.dart';
import 'package:acter_project/screen/service/ui/ui.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:video_player_win/video_player_win.dart' as video;

/// set(image, posX, posY)
class UISoundPlayer extends UI {
  UISoundPlayer({super.key});

  final Map<String, AudioPlayer> audioPlayers = {};

  @override
  bool get isForward => false;

  @override
  State<UISoundPlayer> createState() => UISoundPlayerState();
}

class UISoundPlayerState extends State<UISoundPlayer>
    with TickerProviderStateMixin {
  late DataManager dataManager;

  @override
  void initState() {
    super.initState();

    widget.cmdBinder.bindFunctionToCommand('play', play);
    widget.cmdBinder.bindFunctionToCommand('stop', stop);
    widget.cmdBinder.bindFunctionToCommand('pause', pause);
    widget.cmdBinder.bindFunctionToCommand('resume', resume);
    widget.cmdBinder.bindFunctionToCommand('stopAll', stopAll);
    // add command
    // from, to , time/ms
    dataManager = context.read<DataManager>();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  void play(List<String> args) {
    if (!widget.audioPlayers.containsKey(args[0])) {
      widget.audioPlayers[args[0]] = AudioPlayer();
    }

    widget.audioPlayers[args[0]]!.play(dataManager.sounds[args[0]]!);
  }

  void resume(List<String> args) {
    if (!widget.audioPlayers.containsKey(args[0])) {
      widget.audioPlayers[args[0]] = AudioPlayer();
    }

    widget.audioPlayers[args[0]]!.setSource(dataManager.sounds[args[0]]!);
    widget.audioPlayers[args[0]]!.resume();
  }

  void pause(List<String> args) {
    if (!widget.audioPlayers.containsKey(args[0])) {
      widget.audioPlayers[args[0]] = AudioPlayer();
    }

    widget.audioPlayers[args[0]]!.setSource(dataManager.sounds[args[0]]!);
    widget.audioPlayers[args[0]]!.pause();
  }

  void stop(List<String> args) {
    if (!widget.audioPlayers.containsKey(args[0])) {
      widget.audioPlayers[args[0]] = AudioPlayer();
    }

    widget.audioPlayers[args[0]]!.setSource(dataManager.sounds[args[0]]!);
    widget.audioPlayers[args[0]]!.stop();
  }

  void stopAll(List<String> args) {
    widget.audioPlayers.forEach((key, value) {value.stop();});
  }
}
