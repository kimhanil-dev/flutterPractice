import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path_provider/path_provider.dart';
import 'package:googleapis_auth/auth_io.dart';

// google drive로부터 achivement에 대한 이미지 파일들을 불러옵니다.
// 구문을 반드시 추가해야 합니다.
class AchivementImageLoader {
  static final Map<int, Image> _images = {};
  static late drive.DriveApi _driveApi;
  static late drive.FileList _achiveImageFiles;
  static bool _bIsConnected = false;

  static Future<void> _connect() async {
    if (_bIsConnected) {
      return;
    }

    // connect to google `Drive Api`;
    var client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson(await rootBundle
            .loadString('assets/api-key/google-drive-api-key.json')),
        [drive.DriveApi.driveReadonlyScope]);
    _driveApi = drive.DriveApi(client);

    // quary achivement image meta datas;
    var imageFolder = '1uR1WyjYKLvcdz1EHQCYpPOGuNLK_0a_m';
    _achiveImageFiles =
        await _driveApi.files.list(q: "'$imageFolder' in parents");

    _bIsConnected = true;
  }

  static Future<List<String>> getImageWebLinks() async {
    await _connect();

    var googleWebViewHead = 'https://drive.google.com/uc?export=view&id=';

    List<String> result = [];
    for (var file in _achiveImageFiles.files!) {
      result.add('$googleWebViewHead${file.id}');
    }
    return result;
  }

  static Future<void> downloadImages() async {
    await _connect();

    var directory = await getApplicationDocumentsDirectory();

    for (var file in _achiveImageFiles.files!) {
      var imageKey = int.parse(file.name!.substring(0, file.name!.length - 4));
      io.File mediaFile = io.File('${directory.path}/${file.name}');

      if (!await mediaFile.exists()) {
        List<int> dataStore = [];
        var media = (await _driveApi.files.get(file.id!,
            acknowledgeAbuse: true,
            downloadOptions: drive.DownloadOptions.fullMedia)) as drive.Media;
        media.stream.listen((data) {
          dataStore.insertAll(dataStore.length, data);
        }, onDone: () {
          mediaFile.writeAsBytesSync(dataStore);
          _images[imageKey] = Image.memory(Uint8List.fromList(dataStore));
          print('${file.name} downloaded');
        }, onError: (e) {
          print('image download failed : ${file.name}');
        });
      } else {
        _images[imageKey] = Image.memory(mediaFile.readAsBytesSync());
        print('${file.name} is loaded');
      }
    }
  }

  static Image? getImage(int id) {
    return _images[id];
  }
}
