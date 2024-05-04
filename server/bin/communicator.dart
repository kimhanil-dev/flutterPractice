
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

class Communicator_server implements MessageListener {
  Communicator_server(this.server, this.playManager, this.achivementDB);
  final Server server;
  final PlayManager playManager;
  final AchivementDB achivementDB;
  late Socket _controller;

  @override
  void listen(Socket socket, MessageData msgData) {
    switch (msgData.messageType) {
      case MessageType.onControllerConnected:
        _controller = socket;
        server.sendMessage(
            dest: _controller, msgType: MessageType.answerControllerConnected);
        sendChapterInfo();
        break;
      case MessageType.requestStartThater:
        playManager.changeToNextChapter(achivementDB);
        server.broadcastMessage(messageType: MessageType.onTheaterStarted);
        sendChapterInfo();
        break;
      case MessageType.requestNextChapter:
        playManager.changeToNextChapter(achivementDB);
        sendChapterInfo();
        break;
      case MessageType.requestBroadcastSequenceAchivement:
        playManager.boradcastSequenceAchivement();
        if (playManager.currentSequenceAchivement != null) {
          server.sendMessage(
              dest: _controller,
              msgType: MessageType.answerCurrentSequenceAchive,
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
        server.sendMessage(
            dest: _controller,
            msgType: MessageType.answerPlayerInfos,
            object: batchedData);
        break;
      case MessageType.requestRestartTheater:
        sendChapterInfo();
        break;
      default:
    }
  }

  void sendChapterInfo() {
    server.sendMessage(
        dest: _controller,
        msgType: MessageType.answerCurrentChapter,
        object: IntMessageObject(playManager.currentChaper));
    server.sendMessage(
        dest: _controller,
        msgType: MessageType.answerCurrentSequenceAchive,
        object: IntMessageObject(playManager.currentSequenceAchivement == null
            ? -1
            : playManager.currentSequenceAchivement!.id));
  }

  @override
  void onDone(Socket socket) {
    // TODO: implement onDone
  }
}
