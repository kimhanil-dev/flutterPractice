import 'package:acter_project/client/Services/google_drive_image_downloader.dart';
import 'package:acter_project/screen/service/effect/rpg_maker_animation_loader.dart';
import 'package:acter_project/screen/service/effect/sprite.dart';
import 'package:acter_project/screen/service/message_manager.dart';
import 'package:acter_project/screen/service/screen_message.dart';
import 'package:acter_project/screen/service/screen_effect_sequence_loader.dart';
import 'package:acter_project/screen/service/ui/hp/hp_bar.dart';
import 'package:acter_project/screen/service/ui/hp/hp_bar_list.dart';
import 'package:acter_project/screen/service/ui/image/ui_image.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:theater_publics/public.dart';

import 'effect/screen_effect.dart';
import 'ui/ui.dart';

abstract interface class BackgroundImageSetter {
  void setImage(Image image);
}

abstract interface class UIBuilder {
  void addUI(UI ui);
  void removeUI(UI ui);
}

class ScreenEffectManager implements BackgroundImageSetter, UIBuilder {
  ScreenEffectManager(this.appUpdater, this.ticker);

  final TickerProviderStateMixin ticker;
  MessageManager messageManager = MessageManager();

  int _currentChapter = 0;
  int _currentSFX = -1;
  final Map<int, List<List<ScreenEffect>>> _screenEffects = {};
  final _audioPlayer = AudioPlayer();
  List<ScreenEffect>? _curScreenEffects = [];
  late Image backgroundImage;

  final Map<String, UI> uis = {};
  final List<UI> _activatedUIs = [];

  final NodeWithSize rootNode = NodeWithSize(const Size(1920, 1080));
  late Node vfxParent = Node();

  Map<String, MySprite> sprites = {};
  Map<String,MyAnimation> animations = {};

  List<Widget> getUIs(BuildContext context) {
    return _activatedUIs.map((e) => e.getUI(context)).toList();
  }

  Function() appUpdater;

  Future<void> loadScreenEffects() async {
    backgroundImage = Image.asset('assets/images/bg/bg_0.jpg');

    vfxParent.position = const Offset(1920 / 2, 1080 / 2);
    rootNode.addChild(vfxParent);

    /* load resources from google drive */
    final gdImageDownloader = GoogleDriveDownloader<Image>();
    final images = await gdImageDownloader.downloadFiles(
        '1OSlC6zs94sB4cdCwtnS7hMdHz2zgoi9Q',
        'bgImages',(name, bytes, file) {
          return Resource<Image>(name.split('.')[0],Image.memory(bytes));
        },);

    final gdAudioDownloader = GoogleDriveDownloader<Source>();
    final sounds = await gdAudioDownloader.downloadFiles(
        '1eZUEnNIe3SpWQPthg9M1JuVcMioQJGO9',
        'sounds',
        GoogleDriveDownloader.audioLoader);


    // load animation and
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

    /* -------------------------------  */

    /*UI 생성*/

    uis['hp'] = HpBar(ticker, appUpdater,0, 0)..setWidgetBuilder(this);
    uis['hps'] = HPBarList(ticker, appUpdater)..setWidgetBuilder(this);
    uis['bg'] = UIImage(ticker, appUpdater,images,0,0)..setWidgetBuilder(this);

    /*-----------------------------------*/

    /* load screen effect sequences */
    final dotEnv = DotEnv();
    await dotEnv.load(fileName: 'assets/.env');
    final sfxSequences = await ScreenEffectSequenceLoader.loadData(
        dotEnv.env['GSHEETS_CREDENTIALS']!, 5);
    for (var sfxs in sfxSequences) {
      List<ScreenEffect> effects = [];
      final chapter = int.parse(sfxs[0]);
      if (sfxs[1] != '') {
        // change background
        var commands = sfxs[1].split('.');
        effects.add(CommandEffect(commands, uis[commands[0]]!, chapter, 0, ''));
      }
      if (sfxs[2] != '') {
        // play sound
        effects.add(
            SoundEffect(_audioPlayer, sounds[sfxs[2]]!, chapter, 0, sfxs[2]));
      }
      if (sfxs[3] != '') {
        // play effect
        effects.add(VfxEffect(
            vfxParent,
            sprites,
            animations[sfxs[3]]!,
            chapter,
            0,
            ''));
      }
      if (sfxs[4] != '') {
        var commands = sfxs[4].split('.');
        effects.add(CommandEffect(commands, uis[commands[0]]!,
            chapter, 0, sfxs[4])); // 수정할 것
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
    messageManager.notifyMessage(message);

    switch (message.messageType) {
      case MessageType.onVote:
        //var voteData = VoteData.fromBytes(message.datas);
        
        break;
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

  // WidgetBuilder
  @override
  void addUI(UI ui) {
    _activatedUIs.add(ui);
  }

  @override
  void removeUI(UI ui) {
    _activatedUIs.remove(ui);
  }
  //
}
