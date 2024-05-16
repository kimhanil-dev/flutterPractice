import 'package:acter_project/screen/service/effect/rpg_maker_animation_loader.dart';
import 'package:acter_project/screen/service/effect/sprite.dart';
import 'package:acter_project/screen/service/screen_effect_manager.dart';
import 'package:acter_project/screen/service/ui/hp/hp_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:spritewidget/spritewidget.dart';

import '../ui/ui.dart';

abstract class ScreenEffect {
  ScreenEffect(this.chapter, this.id, this.name);
  int chapter;
  int id;
  String name;

  void startEffect();
  void endEffect();
}

// class ImageEffect extends ScreenEffect {
//   ImageEffect(
//       this._bgImageSetter, this._bgImage, super.chapter, super.id, super.name);

//   final BackgroundImageSetter _bgImageSetter;
//   final Image _bgImage;

//   @override
//   void startEffect() {
//     _bgImageSetter.setImage(_bgImage);
//   }

//   @override
//   void endEffect() {}
// }

class SoundEffect extends ScreenEffect {
  SoundEffect(
      this.audioPlayer, this.audioSource, super.chapter, super.id, super.name);

  final Source audioSource;
  final AudioPlayer audioPlayer;

  @override
  void startEffect() {
    audioPlayer.play(audioSource);
  }

  @override
  void endEffect() {
    audioPlayer.stop();
  }
}

class VfxEffect extends ScreenEffect {
  VfxEffect(this.parent, this.sprites, this.animation, super.chapter, super.id,
      super.name);
  final Node parent;
  final Map<String, MySprite> sprites;
  final MyAnimation animation;

  Future<void> _spawnEffect(Node parent, Frame frame, Duration lifeTime) async {
    SpriteTexture? texture;
    if (frame.spriteIndex < 0) {
      return;
    } else if (frame.spriteIndex >= 100) {
      texture = sprites[animation.sprite2]?.sprites[frame.spriteIndex - 100];
    } else {
      texture = sprites[animation.sprite1]?.sprites[frame.spriteIndex];
    }

    if(texture == null) {
      return;
    }

    Sprite sprite = Sprite(texture: texture);
    sprite.position = Offset(frame.posX.toDouble(), frame.posY.toDouble());
    sprite.scale = frame.scale.toDouble() / 100;

    parent.addChild(sprite);

    await Future.delayed(lifeTime);
    parent.removeChild(sprite);
  }

  @override
  void startEffect() {
    parent.visible = true;

    var lifeTime = const Duration(milliseconds: 50);

    Future.microtask(() async {
      // frame이 여러개가 존재할 예정
      for (var frame in animation.frames) {
        for (var e in frame) {
          _spawnEffect(parent, e, lifeTime);
        }
        await Future.delayed(lifeTime);
      }
    });
  }

  @override
  void endEffect() {
    parent.visible = false;
  }
}

class CommandEffect extends ScreenEffect {
  CommandEffect(this.commands, this.commandManager, super.chapter, super.id, super.name);
  final List<String> commands;
  final CommandManager commandManager;
  @override
  void endEffect() {}

  @override
  void startEffect() {
    commandManager.readCommand(commands);
  }
}
