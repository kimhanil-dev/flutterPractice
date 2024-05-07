import 'dart:async';

import 'package:acter_project/client/Services/client.dart';
import 'package:theater_publics/public.dart';
import 'package:theater_publics/achivement.dart';
import 'package:theater_publics/player.dart';

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
        // update player infos
        Timer.periodic(const Duration(seconds: 2), (timer) {
          _client.sendMessage(message: MessageType.requestPlayerInfos);
        });
        break;
      case MessageType.answerCurrentChapter:
        currentChapter = int.parse(String.fromCharCodes(msgData.datas));
        curChapterAchivs = achivementDB.getChapterAchivements(currentChapter);

        try {
          skipMajority = double.parse(curChapterAchivs
              .singleWhere((element) => element.condition == Condition.skip)
              .data1);
        } on StateError {
          skipMajority = 0;
        }

        try {
          actionMajority = double.parse(curChapterAchivs
              .singleWhere((element) => element.condition == Condition.action)
              .data1);
        } on StateError {
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
    } on StateError {
      return '없음';
    }
  }
}
