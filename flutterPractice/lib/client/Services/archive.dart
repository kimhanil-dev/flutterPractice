import 'dart:io';

import 'package:path_provider/path_provider.dart';

// 업적 데이터 메모리 저장
class Archive {
  Archive();

  Set<int> _achivements = {};

  List<int> get achivements => _achivements.toList();
  set achivements(List<int> value) => _achivements = value.toSet();

  // TODO : 연속으로 호출될때 문제 없는지 확인할 것
  void addAchivement(int achivementId) async {
    if (_achivements.add(achivementId)) {
      await ArchiveSaveLoader.save(this);
    }
  }
}

// 업적 데이터 저장, 불러오기 (로컬 파일 저장)
class ArchiveSaveLoader {
  static Future<void> save(final Archive archive) async {
    var saveFile = '${(await getApplicationCacheDirectory()).path}/archive.sav';
    File file = File(saveFile);
    String buffer = '';
    for (var aID in archive.achivements) {
      buffer+='$aID,';
    }
    file.writeAsStringSync(buffer);
    print('file saved... : ${file.path}');
  }

  static Future<void> load(Archive archive) async {
    var saveFile = '${(await getApplicationCacheDirectory()).path}/archive.sav';
    File file = File(saveFile);
    var rawData = file.readAsStringSync();
    var ids = rawData.split(',');
    List<int> parsedIds = [];
   for(int i = 0; i < (ids.length - 1); ++i) {
    parsedIds.add(int.parse(ids[i]));
   }

   archive.achivements = parsedIds;
  }
}
