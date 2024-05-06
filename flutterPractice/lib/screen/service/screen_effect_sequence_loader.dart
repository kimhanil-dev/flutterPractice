

import 'package:gsheets/gsheets.dart';

class ScreenEffectSequenceLoader {
  
  static Future<List<List<String>>> loadData(String credentials) async {
    const spreadsheetId = '1BFOTkpnw7rSNr8sK1JGCC8z4xEcUGehQ4VatQkPQfEc';
    const worksheetTitle = 'screen';

    // read google spreadsheet
    final gsheets = GSheets(credentials);
    final ss = await gsheets.spreadsheet(spreadsheetId);
    final sheet = ss.worksheetByTitle(worksheetTitle);

    if (sheet == null) {
      throw Exception('$worksheetTitle is not found');
    }


    List<List<String>> result = [];
    // load achivement datas
    var screenEffectsRange = ss.data.namedRanges.byName['screen_effects']?.range;
    int fromRow = screenEffectsRange?.startRowIndex ?? 0;
    int fromColumn = screenEffectsRange?.startColumnIndex ?? 0;
    int count = (screenEffectsRange?.endRowIndex ?? 0) - fromRow;
    int length = (screenEffectsRange?.endColumnIndex ?? 0) - fromColumn;
    var screenEffects = await sheet.cells.allRows(
        fromRow: fromRow + 1,
        fromColumn: fromColumn + 1,
        count: count,
        length: length);
    for (var row in screenEffects) {
      List<String> rowValues = ['','','',''];
      for(var cell in row) {
        rowValues[cell.column - 1] = cell.value;
      }
      result.add(rowValues);
    }

    print("AchivementDB : data loaded (num : ${result.length})");

    return result;
  }
}