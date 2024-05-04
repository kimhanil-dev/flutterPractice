import 'package:acter_project/screen/event_manager.dart';
import 'package:acter_project/screen/main.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:theater_publics/public.dart';

abstract interface class BackgroundImageSetter {
  void setImage(Image image);
}

class ScreenEffectManager implements BackgroundImageSetter {
  ScreenEffectManager(this.appUpdater);
  int _currentChapter = 0;
  int _currentSFX = 0;
  final Map<int, List<ScreenEffect>> _screenEffects = {};
  final AudioPlayer _audioPlayer = AudioPlayer();
  late Image backgroundImage;

  Function() appUpdater;

  void loadScreenEffects() {
    backgroundImage = Image.asset('assets/images/bg/bg_0');

    _screenEffects.addAll({
      1: [
        ImageEffect(this, Image.asset('assets/images/bg/bg_1'), 1, 0, 'test_1'),
      ],
      2: [
        ImageEffect(this, Image.asset('assets/images/bg/bg_2'), 1, 1, 'test_2'),
        SoundEffect(
            _audioPlayer,
            'https://freesound.org/people/misternormmedia/sounds/734375/download/734375__misternormmedia__rain-storm-in-the-city.mp3',
            1,
            2,
            'sound'),
      ]
    });
  }

  ScreenEffect? getCurrentScreenEffect() {
    if (!_screenEffects.containsKey(_currentChapter)) {
      return null;
    }

    if (_currentSFX >= _screenEffects[_currentChapter]!.length) {
      return null;
    }

    return _screenEffects[_currentChapter]![_currentSFX];
  }

  void _setChapter(int chapter) {
    _currentChapter = chapter;
  }

  @override
  void setImage(Image image) {
    backgroundImage = image;
  }

  void onMessage(MessageData message) {
    switch (message.messageType) {
      case MessageType.onChapterChanged:
        _setChapter(message.datas[0]);
        break;
      case MessageType.screenMessage:
        processScreenMessage(ScreenMessage.fromData(message.datas));
        break;
      default:
    }
  }

  void processScreenMessage(ScreenMessage msg) {
    switch (msg.msgType) {
      case MessageType.nextSFX:
        ++_currentSFX;
        var curSFX = getCurrentScreenEffect();
        if (curSFX != null) {
          curSFX.startEffect();
          appUpdater();
        } else {
          Fluttertoast.showToast(msg: 'inavlid sfx : chapter : $_currentChapter : sfx : $_currentSFX');
        }
        break;
      default:
    }
  }
}
