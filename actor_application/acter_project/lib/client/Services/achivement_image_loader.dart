import 'dart:io' as io;

import 'package:flutter/services.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:path_provider/path_provider.dart';
import 'package:googleapis_auth/auth_io.dart';

// google drive로부터 achivement에 대한 이미지 파일들을 불러옵니다.
// 구문을 반드시 추가해야 합니다.
class AchivementImageLoader {

  late DriveApi _driveApi;
  late FileList _achiveImageFiles;
  bool _bIsConnected = false;

  Future<void> _connect() async {
    if (_bIsConnected) {
      return;
    }

    // connect to google `Drive Api`;
    var client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson(
            await rootBundle.loadString('assets/api-key/google-drive-api-key.json')),
        [DriveApi.driveReadonlyScope]);
    _driveApi = DriveApi(client);

    // quary achivement image meta datas;
    var imageFolder = '1uR1WyjYKLvcdz1EHQCYpPOGuNLK_0a_m';
    _achiveImageFiles =
        await _driveApi.files.list(q: "'$imageFolder' in parents");

    _bIsConnected = true;
  }

  Future<List<String>> getImageWebLinks() async {
    await _connect();

    var googleWebViewHead = 'https://drive.google.com/uc?export=view&id=';

    List<String> result = [];
    for (var file in _achiveImageFiles.files!) {
      result.add('$googleWebViewHead${file.id}');
    }
    return result;
  }

  Future<void> downloadImages() async {
    await _connect();

    for (var file in _achiveImageFiles.files!) {
      var media = (await _driveApi.files.get(file.id!,
          acknowledgeAbuse: true,
          downloadOptions: DownloadOptions.fullMedia)) as Media;
      List<int> data = [];
      media.stream.forEach((e) {
        data.addAll(e);
      });

      var directory = await getApplicationDocumentsDirectory();
      io.File mediaFile = io.File('${directory.path}/${file.name}');
      mediaFile.writeAsBytesSync(data);

      print('${file.name} downloaded');
    }
  }
}
