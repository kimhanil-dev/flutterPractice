import 'dart:convert';

import 'package:acter_project/client/Services/google_drive_image_downloader.dart';
import 'package:acter_project/screen/service/effect/rpg_maker_animation_loader.dart';
import 'package:acter_project/screen/service/effect/sprite.dart';
import 'package:audioplayers/audioplayers.dart' as media;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spritewidget/spritewidget.dart';
import 'dart:ui' as ui;
import 'dart:io' as io;

class DataManager {
  late Map<String, Image> bgImages;
  late Map<String, media.Source> sounds;
  late Map<String, MyAnimation> animations = {};
  late Map<String, MySprite> sprites = {};
  late Map<String, ui.Image> fades = {};

  Future<void> loadDatas() async {
    /* load resources from google drive */
    


    // load backgroud images
    final gdImageDownloader = GoogleDriveDownloader<Image>();
    bgImages = await gdImageDownloader.downloadFiles(
      '1OSlC6zs94sB4cdCwtnS7hMdHz2zgoi9Q',
      'bgImages',
      (name, bytes, file) {
        return Resource<Image>(name.split('.')[0], Image.memory(bytes));
      },
    );

    // load sound
    final gdAudioDownloader = GoogleDriveDownloader<media.Source>();
    sounds = await gdAudioDownloader.downloadFiles(
        '1eZUEnNIe3SpWQPthg9M1JuVcMioQJGO9',
        'sounds',
        GoogleDriveDownloader.audioLoader);

    // load animations
    var animationList = await AnimationLoader.loadAnimation();

    Set<String> names = {};
    Set<String> imagePaths = {};
    for (var e in animationList) {
      animations[e.name] = e;

      if (e.sprite1 != '') {
        imagePaths.add('assets/sprites/${e.sprite1}.png');
        names.add(e.sprite1);
      }
      if (e.sprite2 != '') {
        imagePaths.add('assets/sprites/${e.sprite2}.png');
        names.add(e.sprite2);
      }
    }

    var imageMap = ImageMap();
    var needImages = imagePaths.toList();
    var loadedImages = await imageMap.load(needImages);
    for (int i = 0; i < loadedImages.length; ++i) {
      sprites[names.toList()[i]] = MySprite(SpriteTexture(loadedImages[i]));
    }
    //

    var manifest = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = jsonDecode(manifest);
    var fadePaths =
        manifestMap.keys.where((element) => element.contains('fades/'));

    // extract file name
    var fadeNames = fadePaths.map((e) => e.split('/').last.split('.').first).toList();

    List<ui.Image> fadeImages = await imageMap.load(fadePaths.toList());
    for (int i = 0; i < fadeImages.length; ++i) {
      fades[fadeNames[i]] = fadeImages[i]; 
      print('fade image : fadeNames[i]');
    }
      print('fade loaded : ${fades.length}');
  }
}
