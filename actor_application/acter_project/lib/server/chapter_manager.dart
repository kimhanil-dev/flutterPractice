import 'package:acter_project/server/achivement.dart';

class ChapterManager {

  int currentChapter = 0;
  List<AchivementData> curChapterAchivements = [];

  // final List<void Function(bool isSkipExisted, bool isActionExisted)> _onChapterStarts = [];
  final List<void Function()> _onChapterEnds = [];

  // void bindOnChapterStart(void Function(bool isSkipExisted,bool isActionExisted) onChapterStart) {
  //   _onChapterStarts.add(onChapterStart);
  // }
   void bindOnChapterEnd(void Function() onChapterEnd) {
    _onChapterEnds.add(onChapterEnd);
  }

  /// return values
  /// 
  /// first boolean : is skip existed?
  /// 
  /// second boolean : is action existed?
  (bool isSkipExisted, bool isActionExisted) changeToNextChapter(final AchivementDB achivement) {
    //close action
    _closeChapter();

    ++currentChapter;
    curChapterAchivements = achivement.getChapterAchivements(currentChapter);

    // --------- skip과 action 조건식이 존재하는지 검사 (해당 버튼 활성화 여부)
    bool isSkipExisted = false;
    bool isActionExisted = false;

    for(var achivement in curChapterAchivements) {
      isSkipExisted = achivement.condition == Condition.skip ? true : false;
      isActionExisted = achivement.condition == Condition.action ? true : false;
    }

    return (isSkipExisted, isActionExisted);
  }

  void _closeChapter() {
    for (var chapterEndCallback in _onChapterEnds) {
      chapterEndCallback();
    }
  }
}
