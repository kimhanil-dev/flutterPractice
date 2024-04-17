import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:acter_project/public.dart';
import 'package:acter_project/server/achivement.dart';
import 'package:async/async.dart';

/// 클라이언트에게 투표를 진행하고, 찬성, 반대에 따라 등록된 업적을 전달합니다.
enum VoteType implements MessageTransableObject{
  skip,
  action;

  @override
  List<int> getMessage() => [index];
  bool equal(Uint8List msgData) => msgData[0] == (index);
}

class Vote implements MessageListener {
  late AchivementData yayAchivement;
  AchivementData? nayAchivement;
  bool bIsVoteStarted = false;
  late VoteType voteType;
  int majority = 0;
  int voterNum = 0;

  List<Socket> yayers = [];
  List<Socket> nayers = [];
  late Function(bool result, List<Socket> yayers, List<Socket> nayers)
      onVoteEnded;

  void startVote(
      {required VoteType voteType,
      required int majority,
      required Duration voteDuration,
      required AchivementData yayAchivement,
      AchivementData? nayAchivement}) {
    this.voteType = voteType;
    this.majority = majority;
    this.yayAchivement = yayAchivement;
    this.nayAchivement = nayAchivement;
    CancelableOperation.fromFuture(
        Future<void>.delayed(voteDuration).then((value) {
      stopVote(false);
    }));

    bIsVoteStarted = true;
  }

  void stopVote(bool result) {
    sendAchivement(yayers, yayAchivement);
    if(nayAchivement != null) {
      sendAchivement(nayers, nayAchivement!);
    }
    majority = 0;
    voterNum = 0;
    yayers.clear();
    nayers.clear();
    bIsVoteStarted = false;
  }

  void sendAchivement(List<Socket> group,AchivementData achivement) {
    for (var dest in group) {
      MessageHandler.sendMessage(dest, MessageType.onAchivement, object : achivement);
    }
  }

  @override
  void listen(Socket socket, MessageData msgData) {
    if (!bIsVoteStarted) {
      return;
    }

    if (msgData.messageType == MessageType.onButtonClicked) {
      if (voteType.equal(msgData.datas)) {
        yayers.add(socket);
        ++voterNum;
        if (voterNum >= majority) {
          stopVote(true);
        }
      }
    }
  }
}
