import 'dart:io';

import 'package:path_provider/path_provider.dart';

// 업적 데이터 메모리 저장
class Archive {
  Archive();

  Set<int> _achivements = {};

  List<int> get achivements => _achivements.toList();
  set achivements(List<int> value) => _achivements = value.toSet();

  // TODO : 연속으로 호출될때 문제 없는지 확인할 것
  bool addAchivement(int achivementId) {
    if (_achivements.add(achivementId)) {
      ArchiveSaveLoader.save(this);

      return true;
    }

    return false;
  }
}

// 업적 데이터 저장, 불러오기 (로컬 파일 저장)
class ArchiveSaveLoader {
  static Future<void> save(final Archive archive) async {
    var saveFile = '${(await getApplicationCacheDirectory()).path}/archive.sav';
    File file = File(saveFile);
    file
        .writeAsBytes(archive.achivements)
        .then((value) => print('file saved... : ${file.path}'));
  }

  static Future<void> load(Archive archive) async {
    var saveFile = '${(await getApplicationCacheDirectory()).path}/archive.sav';
    File file = File(saveFile);
    archive.achivements = file.readAsBytesSync();
  }
}
