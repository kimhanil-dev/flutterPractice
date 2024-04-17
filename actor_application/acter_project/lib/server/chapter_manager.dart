import 'package:acter_project/server/achivement.dart';
import 'package:acter_project/server/vote.dart';

// 흐름
// 1. 챕터 전환
// 2. 챕터 종료 알림
// 3. 챕터 시작 알림
// 4. 투표 시작
class ChapterManager {
  int currentChapter = -1;
  List<AchivementData> curChapterAchivements = [];
  final List<void Function(bool isSkipExisted, bool isActionExisted)> _onChapterStarts = [];
  final List<void Function()> _onChapterEnds = [];

  final Vote skipVoter = Vote();
  final Vote actionVoter = Vote();

  void bindOnChapterStart(
      void Function(bool isSkipExisted, bool isActionExisted) onChapterStart) {
    _onChapterStarts.add(onChapterStart);
  }

  void bindOnChapterEnd(void Function() onChapterEnd) {
    _onChapterEnds.add(onChapterEnd);
  }

  /// return values
  ///
  /// first boolean : is skip existed?
  ///
  /// second boolean : is action existed?
  (bool isSkipExisted, bool isActionExisted) changeToNextChapter(
      final AchivementDB achivement) {
    //close chapter
    for (var chapterEndCallback in _onChapterEnds) {
      chapterEndCallback();
    }

    ++currentChapter;
    curChapterAchivements = achivement.getChapterAchivements(currentChapter);

    // --------- skip과 action 조건식이 존재하는지 검사 (해당 버튼 활성화 여부)
    bool isSkipExisted = false;
    bool isActionExisted = false;

    for (var achivement in curChapterAchivements) {
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
      skipVoter.startVote(
          voteType: VoteType.skip,
          majority: 1,
          voteDuration: const Duration(days: 1),
          yayAchivement: curChapterAchivements.singleWhere((element) => element.condition == Condition.skip),
          nayAchivement: curChapterAchivements.singleWhere((element) => element.condition == Condition.nskip),
      );
    }
    if (isActionExisted) {
      actionVoter.startVote(
          voteType: VoteType.action,
          majority: 1,
          voteDuration: const Duration(minutes: 1),
          yayAchivement: curChapterAchivements.singleWhere((element) => element.condition == Condition.action),
      );
    }

    print('chapter started : $currentChapter');

    return (isSkipExisted, isActionExisted);
  }

}
