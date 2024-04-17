import 'dart:async';

import 'package:acter_project/public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gsheets/gsheets.dart';


// 스프레드시트 condtion 참조
enum Condition {
  skip,
  nskip,
  complite,
  action,
  sequence,
}

class AchivementData implements MessageTransableObject{
  AchivementData(this.index,this.id,this.chapter,this.condition,this.name,this.message,this.action);
  AchivementData.withRange(List<Cell> range)
  : index = int.parse(range[0].value)
  , id = int.parse(range[1].value)
  , chapter = int.parse(range[2].value)
  , condition = Condition.values[(int.parse(range[1].value)) % 10]
  , name = range[4].value
  , message = range[5].value
  , action = range[6].value;

  final int index;
  final int id;
  final int chapter;
  final Condition condition;
  final String name;
  final String message;
  final String action;
  
  @override
  List<int> getMessage() => id.toString().codeUnits;
}

class AchivementDB {

  Map<int,List<AchivementData>> _chapterAchivements = {}; 

  List<AchivementData> getChapterAchivements(final int chapter) {
    if(!_chapterAchivements.containsKey(chapter)) {
      throw Exception('Chapter : $chapter\'s achivements not founded');
    }
    return _chapterAchivements[chapter]!;
  }

  Future<void> loadData() async {
    await dotenv.load(fileName: 'assets/.env');
    final credentials = dotenv.env['GSHEETS_CREDENTIALS'];
    const spreadsheetId = '1BFOTkpnw7rSNr8sK1JGCC8z4xEcUGehQ4VatQkPQfEc';
    const worksheetTitle = 'achivement';

    // read google spreadsheet
    final gsheets = GSheets(credentials);
    final ss = await gsheets.spreadsheet(spreadsheetId);
    final sheet = ss.worksheetByTitle(worksheetTitle);

    if (sheet == null) {
      throw Exception('$worksheetTitle is not found');
    }

    // load achivement datas
    var achivementRange = ss.data.namedRanges.byName['achivementRows']?.range;
    int fromRow = achivementRange?.startRowIndex ?? 0;
    int fromColumn = achivementRange?.startColumnIndex ?? 0;
    int count = (achivementRange?.endRowIndex ?? 0) - fromRow;
    int length = (achivementRange?.endColumnIndex ?? 0) - fromColumn;
    var achivementDatas = await sheet.cells.allRows(fromRow: fromRow + 1,fromColumn: fromColumn + 1,count: count,length: length);
    for (var row in achivementDatas) {
      var achivement = AchivementData.withRange(row);
      (_chapterAchivements[achivement.chapter] ??= [achivement]).add(achivement);
    }
  }
}


class AchivementManager {
  AchivementDB achivementDB = AchivementDB();

  void init() async {
    await achivementDB.loadData();
  }
}