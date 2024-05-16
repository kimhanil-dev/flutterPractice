import 'package:acter_project/screen/service/message_manager.dart';
import 'package:acter_project/screen/service/screen_message.dart';
import 'package:acter_project/screen/service/screen_effect_sequence_loader.dart';
import 'package:acter_project/screen/service/ui/hp/hp_bar.dart';
import 'package:acter_project/screen/service/ui/hp/hp_bar_list.dart';
import 'package:acter_project/screen/service/ui/image/ui_image.dart';
import 'package:acter_project/screen/service/ui/text_ui.dart';
import 'package:audioplayers/audioplayers.dart' as media;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:theater_publics/public.dart';

import 'data_manager.dart';
import 'effect/screen_effect.dart';
import 'ui/ui.dart';

abstract interface class UIBuilder {
  void addUI(UI ui, bool isForward);
  void removeUI(UI ui, bool isForward);
}

abstract interface class CommandManager {
  void readCommand(List<String> command);
}

class ScreenEffectManager implements CommandManager {
  ScreenEffectManager(this.dataManager, this.appUpdater);

  final DataManager dataManager;

  MessageManager messageManager = MessageManager();

  int _currentChapter = 0;
  int _currentSFX = -1;
  final Map<int, List<List<ScreenEffect>>> _screenEffects = {};
  final _audioPlayer = media.AudioPlayer();
  List<ScreenEffect>? _curScreenEffects = [];

  final Map<String, CommandActor> _cmdActors = {};
  final List<UI> _uis = [];

  final NodeWithSize rootNode = NodeWithSize(const Size(1920, 1080));
  late Node vfxParent = Node();

  Widget getUI(BuildContext context) {
    return Stack(
      children: _uis,
    );
  }

  Function() appUpdater;

  Future<void> loadScreenEffects() async {
    vfxParent.position = const Offset(1920 / 2, 1080 / 2);
    rootNode.addChild(vfxParent);

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

        var commands = sfxs[1].split(';');
        for (var command in commands) {
          effects.add(CommandEffect(command.split('.'), this, chapter, 0, ''));
        }
      }
      if (sfxs[2] != '') {
        // play sound
        effects.add(SoundEffect(
            _audioPlayer, dataManager.sounds[sfxs[2]]!, chapter, 0, sfxs[2]));
      }
      if (sfxs[3] != '') {
        // play effect
        effects.add(VfxEffect(vfxParent, dataManager.sprites,
            dataManager.animations[sfxs[3]]!, chapter, 0, ''));
      }
      if (sfxs[4] != '') {
        var commands = sfxs[4].split(';');
        for (var command in commands) {
          effects.add(CommandEffect(
              command.split('.'), this, chapter, 0, sfxs[4])); // 수정할 것
        }
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

    appUpdater();
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

  @override
  void readCommand(List<String> command) {
    var header = command[0];
    if (header == 'visible') {
      makeUI(command[1], command[2]);
    } else if (header == 'invisible') {
      // remove
      removeUI(command[1]);
    } else {
      _cmdActors[header]!
          .runCommand(command.getRange(1, command.length).toList());
    }
  }

  void makeUI(String type, String name) {
    late UI ui;

    if (type == 'hps') {
      ui = UIHPBarList();
    } else if (type == 'bg') {
      ui = UIImage();
    } else if (type == 'text') {
      ui = UIText();
    }

    _uis.add(ui);
    _cmdActors[name] = ui;
  }

  void removeUI(String name) {
    _uis.remove(_cmdActors[name]);
    _cmdActors.remove(name);
  }
}
