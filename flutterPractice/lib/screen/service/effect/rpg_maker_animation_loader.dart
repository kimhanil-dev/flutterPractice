import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:acter_project/client/Services/google_drive_image_downloader.dart';
import 'package:flutter/material.dart';

class Frame {
  Frame(
      {this.spriteIndex = 0,
      this.posX = 0,
      this.posY = 0,
      this.scale = 0,
      this.rotation = 0,
      this.isMirror = 0,
      this.opacity = 0,
      this.blendMode = 0});

  final int spriteIndex;
  final int posX;
  final int posY;
  final int scale;
  final int rotation;
  final int isMirror;
  final int opacity;
  final int blendMode;

  static List<List<Frame>> parse(List<dynamic> data) {
    List<List<Frame>> result = [];
    for (var frame in data) {
      if (frame.isEmpty) {
        result.add([]);
        continue;
      }

      List<Frame> frames = [];
      for (var e in frame) {
        var frameInfos = e;
        try {
          frames.add(Frame(
              spriteIndex: frameInfos[0],
              posX: frameInfos[1],
              posY: frameInfos[2],
              scale: frameInfos[3],
              rotation: frameInfos[4],
              isMirror: frameInfos[5],
              opacity: frameInfos[6],
              blendMode: frameInfos[7]));
        } on TypeError catch (e) {
          // 만약 frames 리스트에 실수형이 존재한다면, 정수형으로 버림 변환 합니다.
          frameInfos = frameInfos.map((e) => e.floor()).toList();
          frames.add(Frame(
              spriteIndex: frameInfos[0],
              posX: frameInfos[1],
              posY: frameInfos[2],
              scale: frameInfos[3],
              rotation: frameInfos[4],
              isMirror: frameInfos[5],
              opacity: frameInfos[6],
              blendMode: frameInfos[7]));
        }
      }
      result.add(frames);
    }

    return result;
  }

  @override
  String toString() {
    return 'Frame : { spriteIndex : $spriteIndex, posX : $posX, posY : $posY, scale : $scale, rotation : $rotation, isMirror : $isMirror, opacity : $opacity, blendMode : $blendMode }';
  }
}

class Timing {
  Timing(this.flashColor, this.flashDuration, this.frame, this.sound,
      this.soundVolume);
  final Color flashColor;
  final Duration flashDuration;
  final int frame;
  final String sound;
  final int soundVolume;

  static List<Timing> parse(List<dynamic> data) {
    List<Timing> result = [];
    for (var e in data) {
      result.add(Timing(
        Color.fromARGB(
            255, e['flashColor'][0], e['flashColor'][1], e['flashColor'][2]),
        Duration(seconds: e['flashDuration']),
        e['frame'],
        e['se']?['name'] ?? '',
        e['se']?['volume'] ?? 0,
      ));
    }

    return result;
  }

  @override
  String toString() {
    return 'Timing { flashColor : $flashColor, flashDuration : $flashDuration, frame : $frame, sound : $sound, sound volume : $soundVolume}';
  }
}

class MyAnimation {
  MyAnimation(this.name, this.sprite1, this.sprite2, this.frames, this.timings);

  final String name;
  final String sprite1;
  final String sprite2;
  final List<List<Frame>> frames;
  final List<Timing> timings;

  static List<MyAnimation> parse(List<dynamic> jsonData) {
    List<MyAnimation> result = [];
    try {
      for (var element in jsonData) {
        if (element == null) {
          continue;
        }

        result.add(MyAnimation(
          element['name'],
          element['animation1Name'],
          element['animation2Name'],
          element['frames'],
          element['timings'],
        ));
      }
    } on Exception catch (e) {
      print('Animation.parse failed : $e');
      assert(false);
    }

    return result;
  }

  @override
  String toString() {
    return 'name : $name {sprite1 : $sprite1, sprite2 : $sprite2, $frames, $timings}';
  }
}

class AnimationLoader {
  static Future<List<MyAnimation>> loadAnimation() async {
    final gdDownloader = GoogleDriveDownloader<List<dynamic>>();
    var data = await gdDownloader.downloadFiles(
        '18olrVdLQcdev7yBWPVn_Y1pP8goeNSQl',
        'animation',
        loadAnimationFromJson);
    return MyAnimation.parse(data['Animations.json']!);
  }

  static Resource<List<dynamic>> loadAnimationFromJson(
      String name, Uint8List bytes, File file) {
    var data = jsonDecode(
      String.fromCharCodes(bytes),
      reviver: (key, value) {
        if (key == 'frames') {
          return Frame.parse(value as List<dynamic>);
        } else if (key == 'timings') {
          return Timing.parse(value as List<dynamic>);
        }

        return value;
      },
    );

    return Resource<List<dynamic>>(name, data);
  }
}
