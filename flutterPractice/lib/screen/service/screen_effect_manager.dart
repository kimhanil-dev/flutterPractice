import 'package:acter_project/client/Services/google_drive_image_downloader.dart';
import 'package:acter_project/screen/service/screen_message.dart';
import 'package:acter_project/screen/main.dart';
import 'package:acter_project/screen/service/screen_effect_sequence_loader.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:theater_publics/public.dart';

abstract interface class BackgroundImageSetter {
  void setImage(Image image);
}

class ScreenEffectManager implements BackgroundImageSetter {
  ScreenEffectManager(this.appUpdater);

  int _currentChapter = 0;
  int _currentSFX = -1;
  final Map<int, List<List<ScreenEffect>>> _screenEffects = {};
  final _audioPlayer = AudioPlayer();
  List<ScreenEffect>? _curScreenEffects = [];
  late Image backgroundImage;

  Function() appUpdater;

  Future<void> loadScreenEffects() async {
    backgroundImage = Image.asset('assets/images/bg/bg_0.jpg');

    /* load resources from google drive */
    final gdImageDownloader = GoogleDriveDownloader<Image>();
    final images = await gdImageDownloader.downloadFiles(
        '1OSlC6zs94sB4cdCwtnS7hMdHz2zgoi9Q',
        'bgImages',
        GoogleDriveDownloader.imageLoader);

    final gdAudioDownloader = GoogleDriveDownloader<Source>();
    final sounds = await gdAudioDownloader.downloadFiles(
        '1eZUEnNIe3SpWQPthg9M1JuVcMioQJGO9',
        'sounds',
        GoogleDriveDownloader.audioLoader);
    /* -------------------------------  */

    /* load screen effect sequences */
    final dotEnv = DotEnv();
    await dotEnv.load(fileName: 'assets/.env');
    final sfxSequences = await ScreenEffectSequenceLoader.loadData(
        dotEnv.env['GSHEETS_CREDENTIALS']!);
    for (var sfxs in sfxSequences) {
      List<ScreenEffect> effects = [];
      final chapter = int.parse(sfxs[0]);
      if (sfxs[1] != '') {
        // change background
        effects.add(ImageEffect(this, images[sfxs[1]]!, chapter, 0, sfxs[1]));
      }
      if (sfxs[2] != '') {
        // play sound
        effects.add(
            SoundEffect(_audioPlayer, sounds[sfxs[2]]!, chapter, 0, sfxs[2]));
      }
      if (sfxs[3] != '') {
        // play effect
        //effects.add(SoundEffect(_audioPlayer, sounds[sfxs[2]]!, chapter, 0, sfxs[2]));
      }

      if (_screenEffects[chapter] == null) {
        _screenEffects[chapter] = [];
      }

      _screenEffects[chapter]!.add(effects);
    }
    /* ---------------------------------- */
  }

  List<ScreenEffect>? getCurrentScreenEffect() {
    if (!_screenEffects.containsKey(_currentChapter)) {
      return null;
    }

    if (_currentSFX >= _screenEffects[_currentChapter]!.length) {
      return null;
    }

    return _screenEffects[_currentChapter]![_currentSFX];
  }

  void _nextChapter() {
    _endPrevEffects();

    ++_currentChapter;
    _currentSFX = -1;
    backgroundImage = Image.asset('assets/images/bg/bg_0.jpg');

    appUpdater();
  }

  @override
  void setImage(Image image) {
    backgroundImage = image;
  }

  void onMessage(MessageData message) {
    switch (message.messageType) {
      case MessageType.requestRestartTheater:
        _currentChapter = 0;
        _currentSFX = -1;
        break;
      case MessageType.screenMessage:
        processScreenMessage(ScreenMessage.fromData(message.datas));
        break;
      default:
    }
  }

  void processScreenMessage(ScreenMessage msg) {
    switch (msg.msgType) {
      case MessageType.onChapterChanged:
        _nextChapter();
        break;
      case MessageType.nextSFX:
        _endPrevEffects();

        // start next screen effects
        ++_currentSFX;
        _curScreenEffects = getCurrentScreenEffect();
        if (_curScreenEffects != null) {
          for (var e in _curScreenEffects!) {
            e.startEffect();
          }
          appUpdater();
        } else {
          print(
              'inavlid sfx : chapter : $_currentChapter : sfx : $_currentSFX');
        }
        break;
      default:
    }
  }

  void _endPrevEffects() {
    if (_curScreenEffects != null) {
      for (var e in _curScreenEffects!) {
        e.endEffect();
      }
    }
  }
}
