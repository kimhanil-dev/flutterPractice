import 'dart:io';

import 'package:theater_publics/public.dart';
import 'package:theater_publics/achivement.dart';
import 'package:theater_publics/player.dart';
import 'package:theater_publics/vote.dart';

import 'server.dart';
import 'vote.dart';


// 흐름
// 1. 챕터 전환
// 2. 챕터 종료 알림
// 3. 챕터 시작 알림
// 4. 투표 시작
class PlayManager implements MessageListener, MessageWriter {
  PlayManager() {
    _skipVote = Vote(onSkipVoted, onVoteIncrease: onSkipVoteIncrease);
    _actionVote = Vote(onActionVoted, onVoteIncrease: onActionVoteIncrease);
  }

  bool _isSkipped = false;
  int _currentChapter = -1;
  AchivementData? _curSkipAchivement;
  AchivementData? _curActionAchivement;
  List<AchivementData> _curSequenceAchivement = [];

  int get currentChaper => _currentChapter;
  AchivementData? get currenSkipAchivement => _curSkipAchivement;
  AchivementData? get currentActionAchivement => _curActionAchivement;
  List<AchivementData> get currentSequenceAchives => _curSequenceAchivement;
  AchivementData? get currentSequenceAchivement => _getCurSequenceAchivement();

  int get skipMajority => (clients.length *
          (_curSkipAchivement != null
              ? double.parse(_curSkipAchivement!.data1)
              : 0))
      .round();
  int get actionMajority => (clients.length *
          (_curActionAchivement != null
              ? double.parse(_curActionAchivement!.data1)
              : 0))
      .round();

  AchivementData? _getCurSequenceAchivement() {
    if (_sequenceCounter < _curSequenceAchivement.length) {
      return _curSequenceAchivement[_sequenceCounter];
    }
    return null;
  }

  List<AchivementData> get curChapterAchives => _curChapterAchives;
  List<AchivementData> get curChapterSequenceAchives => _curSequenceAchivement;

  List<AchivementData> _curChapterAchives = [];
  int _sequenceCounter = 0;

  final List<void Function(bool isSkipExisted, bool isActionExisted)>
      _onChapterStarts = [];
  final List<void Function()> _onChapterEnds = [];

  late Vote _skipVote;
  late Vote _actionVote;

  final List<Socket> clients = [];
  final Map<Socket, Player> _players = {};

  List<Player> get players => _players.values.toList();

  void onActionVoteIncrease(Socket voter, int count) {}

  void onSkipVoteIncrease(Socket voter, int count) {}

  void bindOnChapterStart(
      void Function(bool isSkipExisted, bool isActionExisted) onChapterStart) {
    _onChapterStarts.add(onChapterStart);
  }

  void bindOnChapterEnd(void Function() onChapterEnd) {
    _onChapterEnds.add(onChapterEnd);
  }

  int getCurrentSkipVoted() {
    return _skipVote.voteCount;
  }

  int getCurrentActionVoted() {
    return _actionVote.voteCount;
  }

  void onSkipVoted(bool result) {
    _isSkipped = result;
  }

  void onActionVoted(bool result) {
    // TODO
  }

  /// return values
  ///
  /// first boolean : is skip existed?
  ///
  /// second boolean : is action existed?
  (bool isSkipExisted, bool isActionExisted) changeToNextChapter(
      final AchivementDB achivement) {
    _closeChapter();

    ++_currentChapter;
    _curChapterAchives = achivement.getChapterAchivements(_currentChapter);

    // --------- Sequence 업적 탐색
    _curSequenceAchivement = _curChapterAchives
        .where((element) => element.condition == Condition.sequence)
        .toList();
    _sequenceCounter = 0;

    // --------- skip과 action 조건식이 존재하는지 검사 (해당 버튼 활성화 여부)
    bool isSkipExisted = false;
    bool isActionExisted = false;

    for (var achivement in _curChapterAchives) {
      if (achivement.condition == Condition.skip) {
        isSkipExisted = true;
      } else if (achivement.condition == Condition.action) {
        isActionExisted = true;
      }
    }

    for (var chapterStartCallback in _onChapterStarts) {
      chapterStartCallback(isSkipExisted, isActionExisted);
    }

    _curSkipAchivement = _curChapterAchives
        .singleWhere((element) => element.condition == Condition.skip);

    try {
      _curActionAchivement = _curChapterAchives
          .singleWhere((element) => element.condition == Condition.action);
    } on StateError catch (e) {
      _curActionAchivement = null;
    }

    // ---------- 투표 진행
    if (isSkipExisted) {
      _skipVote.startVote(
        voteType: VoteType.skip,
        voteDuration: const Duration(days: 1),
        yayAchivement: _curSkipAchivement!,
        nayAchivement: _curChapterAchives
            .singleWhere((element) => element.condition == Condition.nskip),
      );
    }
    if (isActionExisted) {
      _actionVote.startVote(
        voteType: VoteType.action,
        voteDuration: const Duration(minutes: 1),
        yayAchivement: _curActionAchivement!,
      );
    }

    print('chapter started : $_currentChapter');

    return (isSkipExisted, isActionExisted);
  }

  void _closeChapter() {
    for (var chapterEndCallback in _onChapterEnds) {
      chapterEndCallback();
    }

    if (_isSkipped) {
      _isSkipped = false;
      return;
    }

    // skip이 되지 않았다면 complite 업적 전달
    try {
      var compliteAchivement = _curChapterAchives
          .singleWhere((element) => element.condition == Condition.complite);

      for (var client in clients) {
        MessageHandler.sendMessage(client, MessageType.onAchivement,
            object: compliteAchivement);
      }
    } on StateError catch (e) {
      if (_currentChapter > 0) {
        // 1번 챕터부터는 complite가 존재해야 함
        assert(false);
      }
    }
  }

  bool boradcastSequenceAchivement() {
    if (_sequenceCounter < _curSequenceAchivement.length) {
      for (var client in clients) {
        MessageHandler.sendMessage(client, MessageType.onAchivement,
            object: _curSequenceAchivement[_sequenceCounter]);
      }
      ++_sequenceCounter;
      return true;
    }

    return false;
  }

  @override
  void listen(Socket socket, MessageData msgData) {
    _skipVote.listen(socket, msgData);
    _actionVote.listen(socket, msgData);

    if(msgData.messageType == MessageType.requestRestartTheater) {
      _currentChapter = -1;
      _curChapterAchives.clear();
      _curSequenceAchivement.clear();
      _curActionAchivement = null;
      _curSkipAchivement = null;
      _sequenceCounter = 0;
      
      _isSkipped = false;
      _skipVote.init();
      _actionVote.init();
    }
  }

  int _idPool = 0;
  @override
  void onRegistered(List<Socket> sockets) {
    for (var e in sockets) {
      _players[e] = Player(e, _idPool++);
    }
    clients.addAll(sockets);
    _skipVote.onRegistered(sockets);
    _actionVote.onRegistered(sockets);
  }

  @override
  void onSocketConnected(Socket newSocket) {
    _players[newSocket] = Player(newSocket,_idPool++);
    clients.add(newSocket);
    _skipVote.onSocketConnected(newSocket);
    _actionVote.onSocketConnected(newSocket);
  }

  void pingListener(Ping ping) {
    _players[ping.dest]!.ping = ping.millisec;
  }
  
  @override
  void onDone(Socket socket) {
    _skipVote.onDone(socket);
    _actionVote.onDone(socket);
    _players.remove(socket);
  }
}
