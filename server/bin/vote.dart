import 'dart:async';
import 'dart:io';

import 'package:theater_publics/achivement.dart';
import 'package:theater_publics/public.dart';
import 'package:theater_publics/vote.dart';

import 'package:async/async.dart';


class Vote implements MessageListener, MessageWriter {
  Vote(this.onVoteEnded, {this.onVoteIncrease});

  void Function(Socket newVoter, int num)? onVoteIncrease;

  AchivementData? _yayAchivement;
  AchivementData? _nayAchivement;
  bool _bIsVoteStarted = false;
  late VoteType _voteType;
  double _majority = 0.0;
  int _voteCount = 0;

  int get voteCount => _voteCount;

  final Map<Socket, bool> _voters = {};

  CancelableOperation<Null>? voteTimer;

  final void Function(bool result) onVoteEnded;

  void init() {
    _yayAchivement = null;
    _nayAchivement = null;
    _bIsVoteStarted = false;
    _voteCount = 0;
    _voters.forEach((key, value) {
      value = false;
    });
    if (voteTimer != null) {
      voteTimer!.cancel();
    }
  }

  void startVote(
      {required VoteType voteType,
      required Duration voteDuration,
      required AchivementData yayAchivement,
      AchivementData? nayAchivement}) {
    _voteType = voteType;
    _majority = double.parse(yayAchivement.data1);
    _yayAchivement = yayAchivement;
    _nayAchivement = nayAchivement;

    if (voteTimer != null) {
      voteTimer!.cancel();
    } else {
      voteTimer = CancelableOperation.fromFuture(
          Future<void>.delayed(voteDuration).then((value) {
        stopVote(false);
      }));
    }

    _bIsVoteStarted = true;
  }

  void stopVote(bool result) {
    // send achivement to
    _voters.forEach((socket, voted) {
      sendAchivement(socket, voted ? _yayAchivement! : _nayAchivement!);
      voted = false;
    });

    // send vote complite
    _voters.forEach((socket, voted) {
      MessageHandler.sendMessage(socket, MessageType.onVoteComplited,
          object: _voteType);
    });

    voteTimer!.cancel();
    _majority = 0;
    _voteCount = 0;
    _bIsVoteStarted = false;

    onVoteEnded(result);
  }

  void sendAchivement(Socket dest, AchivementData achivement) {
    MessageHandler.sendMessage(dest, MessageType.onAchivement,
        object: achivement);
  }

  @override
  void listen(Socket socket, MessageData msgData) {
    if (!_bIsVoteStarted || _voters.isEmpty) {
      return;
    }

    if (msgData.messageType == MessageType.onButtonClicked) {
      if (_voteType.equal(msgData.datas)) {
        _voters[socket] = true;
        ++_voteCount;
        if (onVoteIncrease != null) {
          onVoteIncrease!(socket, _voteCount);
        }
        if (_voteCount >= (_voters.length * _majority).floor()) {
          stopVote(true);
        }
      }
    }
  }

  @override
  void onRegistered(List<Socket> sockets) {
    for (var socket in sockets) {
      _voters[socket] = false;
    }
  }

  @override
  void onSocketConnected(Socket newSocket) {
    _voters[newSocket] = false;
  }

  @override
  void onDone(Socket socket) {
    _voters.remove(socket);
  }
}
