import 'dart:async';
import 'dart:typed_data';

import 'package:acter_project/public.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gsheets/gsheets.dart';

// 스프레드시트 condtion 참조
enum Condition {
  skip,
  nskip,
  complite,
  action,
  sequence;

  static Condition convert(String achivementId) => Condition.values[
      int.parse(achivementId.characters.elementAt(achivementId.length - 2))];
}

class AchivementData implements MessageTransableObject {
  AchivementData(this.index, this.id, this.chapter, this.condition, this.name,
      this.data1, this.data2);
  AchivementData.withRange(List<Cell> range)
      : index = int.parse(range[0].value),
        id = int.parse(range[1].value),
        chapter = int.parse(range[2].value),
        condition = Condition.convert(range[1].value),
        name = range[4].value,
        data1 = range[5].value,
        data2 = range[6].value;

  final int index;
  final int id;
  final int chapter;
  final Condition condition;
  final String name;
  final String data1;
  final String data2;

  @override
  List<int> getMessage() => id.toString().codeUnits.toList();

  @override
  bool equal(Uint8List data) {
    var idCodes = getMessage();
    for (int i = 0; i < data.length; ++i) {
      if (data[i] != idCodes[i]) {
        return false;
      }
    }

    return true;
  }

}

class AchivementDB {
  final Map<int, AchivementData> _achivements = {};

  AchivementData? getAchivementData(int id) {
    return _achivements[id];
  }

  List<AchivementData> getChapterAchivements(final int chapter) {
    List<AchivementData> result = [];
    _achivements.forEach((key, value) {
      if (value.chapter == chapter) {
        result.add(value);
      }
    });

    return result;
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
    var achivementRange = ss.data.namedRanges.byName['achivementRange']?.range;
    int fromRow = achivementRange?.startRowIndex ?? 0;
    int fromColumn = achivementRange?.startColumnIndex ?? 0;
    int count = (achivementRange?.endRowIndex ?? 0) - fromRow;
    int length = (achivementRange?.endColumnIndex ?? 0) - fromColumn;
    var achivementDatas = await sheet.cells.allRows(
        fromRow: fromRow + 1,
        fromColumn: fromColumn + 1,
        count: count,
        length: length);
    for (var row in achivementDatas) {
      var achivement = AchivementData.withRange(row);
      _achivements[achivement.id] = achivement;
    }

    print("AchivementDB : data loaded (num : ${achivementDatas.length})");
  }
}
