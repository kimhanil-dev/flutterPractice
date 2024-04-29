import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:acter_project/client/Services/client.dart';
import 'package:acter_project/public.dart';
import 'package:acter_project/server/achivement.dart';
import 'package:acter_project/server/play_manager.dart';
import 'package:acter_project/server/player_information.dart';
import 'package:acter_project/server/server.dart';

class Communicator_controller {
  Communicator_controller(this.achivementDB, this.refreshFunc);
  final Client _client = Client(clientType: Who.controller);
  final AchivementDB achivementDB;
  final Map<MessageType, void Function()> messageCallbacks = {};

  List<AchivementData> curChapterAchivs = [];
  int currentSequenceAchivement = -1;
  int currentChapter = -1;

  int skipVoteCount = 0;
  int actionVoteCount = 0;

  List<Player_trans> players = [];

  double skipMajority = 0;
  double actionMajority = 0;

  Function() refreshFunc;

  void connect(String serverIp, int serverPort) {
    _client.connectToServer(serverIp, serverPort, onConnected);
    _client.addMessageListener(listen);
  }

  void onConnected(bool result) {
    if (result) {
      _client.sendMessage(message: MessageType.onControllerConnected);
      Timer.periodic(const Duration(seconds: 2), (timer) {
        _client.sendMessage(message: MessageType.requestPlayerInfos);
      });
    } else {
      print('connection failed');
    }
  }

  void sendMessage(MessageType message, {MessageTransableObject? data}) {
    _client.sendMessage(message: message, object: data);
  }

  void listen(MessageData msgData) {
    switch (msgData.messageType) {
      case MessageType.answerControllerConnected:
        _client.sendMessage(message: MessageType.requestCurrentChapter);
        break;
      case MessageType.answerCurrentChapter:
        currentChapter = int.parse(String.fromCharCodes(msgData.datas));
        curChapterAchivs = achivementDB.getChapterAchivements(currentChapter);

        try {
          skipMajority = double.parse(curChapterAchivs
              .singleWhere((element) => element.condition == Condition.skip)
              .data1);
        } on StateError catch (e) {
          skipMajority = 0;
        }

        try {
          actionMajority = double.parse(curChapterAchivs
              .singleWhere((element) => element.condition == Condition.action)
              .data1);
        } on StateError catch (e) {
          actionMajority = 0;
        }

        break;
      case MessageType.answerCurrentSequenceAchive:
        currentSequenceAchivement =
            int.parse(String.fromCharCodes(msgData.datas));
        break;
      case MessageType.answerPlayerInfos:
        players = Player_trans.unbatchPlayers(msgData.datas);
        for (var e in players) {
          skipVoteCount += e.isSkipVoted ? 1 : 0;
          actionVoteCount += e.isActionVoted ? 1 : 0;
        }
        break;
      default:
    }

    var callback = messageCallbacks[msgData.messageType];
    if (callback != null) {
      callback();
    } else {
      refreshFunc();
    }
  }

  String getCurSequenceAchiveName() {
    try {
      return curChapterAchivs
          .singleWhere((element) => element.id == currentSequenceAchivement)
          .name;
    } on StateError catch (e) {
      return '없음';
    }
  }
}

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
