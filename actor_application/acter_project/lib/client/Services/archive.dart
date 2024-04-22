
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Archive {
  Archive();

  Set<int> _achivements = {};

  List<int> get achivements => _achivements.toList();
  set achivements(List<int> value) => _achivements = value.toSet();

  // TODO : 연속으로 호출될때 문제 없는지 확인할 것
  bool addAchivement(int achivementId) {

    if(_achivements.add(achivementId)) {
      ArchiveSaveLoader.save(this);

      return true;
    }

    return false;
  }
}

class ArchiveSaveLoader {

  static Future<void> save(final Archive archive) async {
    var saveFile = '${(await getApplicationCacheDirectory()).path}/archive.sav';
    File file = File(saveFile);
    file.writeAsBytesSync(archive.achivements);
    print('file saved... : ${file.path}');
  }

  static Future<void> load(Archive archive) async {
    var saveFile = '${(await getApplicationCacheDirectory()).path}/archive.sav';
    File file = File(saveFile);
    archive.achivements = file.readAsBytesSync();
  }
}