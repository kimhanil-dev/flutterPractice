import 'dart:io';
import 'dart:typed_data';

import 'package:theater_publics/achivement.dart';
import 'package:theater_publics/player.dart';
import 'package:theater_publics/public.dart';

import 'play_manager.dart';
import 'server.dart';

class IntMessageObject implements MessageTransableObject {
  IntMessageObject(this.data);
  final int data;

  @override
  bool equal(Uint8List data) {
    return String.fromCharCodes(data) == '${this.data}';
  }

  @override
  Uint8List getMessage() {
    return Uint8List.fromList('$data'.codeUnits);
  }
}

class Communicator_server implements MessageListener, PlayInfoListener {
  Communicator_server(this.server, this.playManager, this.achivementDB);
  final Server server;
  final PlayManager playManager;
  final AchivementDB achivementDB;
  Socket? _controller;
  Socket? _screen;

  @override
  void listen(Socket socket, MessageData msgData) {
    switch (msgData.messageType) {
      case MessageType.reqeustWhoAryYou:
        if (msgData.datas[0] == Who.screen.index) {
          _screen = socket;
          print('screen connected');
        } else if (msgData.datas[0] == Who.controller.index) {
          _controller = socket;
          print('controller connected');
        }
        break;
      case MessageType.screenMessage:
        // pass through
        sendMessage(_screen, MessageType.screenMessage,
            object: BytesData(msgData.datas));
        break;
      case MessageType.onControllerConnected:
        _controller = socket;
        sendMessage(_controller, MessageType.answerControllerConnected);
        sendChapterInfo();
        break;
      case MessageType.requestStartThater:
        server.broadcastMessage(messageType: MessageType.onTheaterStarted);
        changeToNextChapter();
        break;
      case MessageType.requestNextChapter:
        changeToNextChapter();
        break;
      case MessageType.requestBroadcastSequenceAchivement:
        playManager.boradcastSequenceAchivement();
        if (playManager.currentSequenceAchivement != null) {
          sendMessage(_controller, MessageType.answerCurrentSequenceAchive,
              object: IntMessageObject(
                  playManager.currentSequenceAchivement == null
                      ? -1
                      : playManager.currentSequenceAchivement!.id));
        }
        break;
      case MessageType.requestCurrentChapter:
        sendChapterInfo();
      case MessageType.requestPlayerInfos:
        var batchedData = Player_trans.batchPlayers(playManager.players);
        sendMessage(_controller, MessageType.answerPlayerInfos,
            object: batchedData);
        break;
      case MessageType.requestRestartTheater:
        playManager.initTheater();
        sendChapterInfo();
        sendMessage(_screen, MessageType.requestRestartTheater);
        break;
      case MessageType.onChapterEnd:
      playManager.closeChapter();
        break;
      default:
    }
  }

  void changeToNextChapter() {
    
    var buttonStates = playManager.changeToNextChapter(achivementDB);
    server.broadcastMessage(messageType: MessageType.onUpdateButtonState, object : ButtonStates(buttonStates.$1,buttonStates.$2));
    sendChapterInfo();
  }

  void sendMessage(Socket? dest, MessageType messageType,
      {MessageTransableObject? object}) {
    if (dest == null) {
      print('commnunicator : sendMessage() : ${messageType.name} : destination not initialized');
      return;
    }

    server.sendMessage(dest: dest, msgType: messageType, object: object);
  }

  void sendChapterInfo() {
    sendMessage(_controller, MessageType.answerCurrentChapter,
        object: IntMessageObject(playManager.currentChaper));
    sendMessage(_controller, MessageType.answerCurrentSequenceAchive,
        object: IntMessageObject(playManager.currentSequenceAchivement == null
            ? -1
            : playManager.currentSequenceAchivement!.id));
  }

  @override
  void onDone(Socket socket) {
    // TODO: implement onDone
  }

  @override
  void onPlayInfo(Condition condition, {AchivementData? achivement}) {
    if (_screen != null) {
      server.sendMessage(
          dest: _screen!,
          msgType: MessageType.onAchivement,
          object: achivement);
    }
  }
}
