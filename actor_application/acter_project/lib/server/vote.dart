import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:acter_project/public.dart';
import 'package:async/async.dart';

enum VoteType {
  skip,
  action;

  bool equal(Uint8List msgData) => msgData[0] == (index);
}

class Vote implements MessageListener {
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
      required Function(bool result, List<Socket> yayers, List<Socket> nayers)
          onVoteEnded}) {
    this.voteType = voteType;
    this.majority = majority;
    this.onVoteEnded = onVoteEnded;
    CancelableOperation.fromFuture(
        Future<void>.delayed(voteDuration).then((value) {
      stopVote(false);
    }));

    bIsVoteStarted = true;
  }

  void stopVote(bool result) {
    onVoteEnded(result, yayers, nayers);
    majority = 0;
    voterNum = 0;
    yayers.clear();
    nayers.clear();
    bIsVoteStarted = false;
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
