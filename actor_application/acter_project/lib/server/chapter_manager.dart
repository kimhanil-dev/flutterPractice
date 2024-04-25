import 'dart:io';

import 'package:acter_project/public.dart';
import 'package:acter_project/server/achivement.dart';
import 'package:acter_project/server/vote.dart';

// 흐름
// 1. 챕터 전환
// 2. 챕터 종료 알림
// 3. 챕터 시작 알림
// 4. 투표 시작
class ChapterManager implements MessageListener, MessageWriter {
  ChapterManager() {
    _skipVote = Vote(onSkipVoted);
    _actionVote = Vote(onActionVoted);
  }

  bool _isSkipped = false;
  int _currentChapter = -1;
  List<AchivementData> _curChapterAchivements = [];
  final List<void Function(bool isSkipExisted, bool isActionExisted)>
      _onChapterStarts = [];
  final List<void Function()> _onChapterEnds = [];

  late Vote _skipVote;
  late Vote _actionVote;

  List<Socket> clients = [];

  void bindOnChapterStart(
      void Function(bool isSkipExisted, bool isActionExisted) onChapterStart) {
    _onChapterStarts.add(onChapterStart);
  }

  void bindOnChapterEnd(void Function() onChapterEnd) {
    _onChapterEnds.add(onChapterEnd);
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
    _curChapterAchivements = achivement.getChapterAchivements(_currentChapter);

    // --------- skip과 action 조건식이 존재하는지 검사 (해당 버튼 활성화 여부)
    bool isSkipExisted = false;
    bool isActionExisted = false;

    for (var achivement in _curChapterAchivements) {
      if (achivement.condition == Condition.skip) {
        isSkipExisted = true;
      } else if (achivement.condition == Condition.action) {
        isActionExisted = true;
      }
    }

    for (var chapterStartCallback in _onChapterStarts) {
      chapterStartCallback(isSkipExisted, isActionExisted);
    }

    // ---------- 투표 진행
    if (isSkipExisted) {
      _skipVote.startVote(
        voteType: VoteType.skip,
        voteDuration: const Duration(days: 1),
        yayAchivement: _curChapterAchivements
            .singleWhere((element) => element.condition == Condition.skip),
        nayAchivement: _curChapterAchivements
            .singleWhere((element) => element.condition == Condition.nskip),
      );
    }
    if (isActionExisted) {
      _actionVote.startVote(
        voteType: VoteType.action,
        voteDuration: const Duration(minutes: 1),
        yayAchivement: _curChapterAchivements
            .singleWhere((element) => element.condition == Condition.action),
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

    try {
      for (var client in clients) {
        MessageHandler.sendMessage(client, MessageType.onAchivement,
            object: _curChapterAchivements.singleWhere(
                (element) => element.condition == Condition.complite));
      }
    } catch (e) {
      if (e is StateError) {
        assert(_currentChapter ==
            -1); // complite achivement is not found in relative database
      }
    }
  }

  @override
  void listen(Socket socket, MessageData msgData) {
    _skipVote.listen(socket, msgData);
    _actionVote.listen(socket, msgData);
  }

  @override
  void onRegistered(List<Socket> sockets) {
    clients.addAll(sockets);
    _skipVote.onRegistered(sockets);
    _actionVote.onRegistered(sockets);
  }

  @override
  void onSocketConnected(Socket newSocket) {
    clients.add(newSocket);
    _skipVote.onSocketConnected(newSocket);
    _actionVote.onSocketConnected(newSocket);
  }
}
