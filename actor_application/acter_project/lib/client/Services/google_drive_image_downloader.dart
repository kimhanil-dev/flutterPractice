import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path_provider/path_provider.dart';
import 'package:googleapis_auth/auth_io.dart';

class GoogleDriveImageDownloader {

  /// return Map's key value is 'IdNumber.png' style 
  static Future<Map<String, Image>> downloadImages() async {
    final Map<String, Image> result = {};

    // connect to google `Drive Api`;
    var client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson(await rootBundle
            .loadString('assets/api-key/google-drive-api-key.json')),
        [drive.DriveApi.driveReadonlyScope]);
    var driveApi = drive.DriveApi(client);

    // quary achivement image meta datas;
    var imageFolder = '1uR1WyjYKLvcdz1EHQCYpPOGuNLK_0a_m';
    var achiveImageFiles =
        await driveApi.files.list(q: "'$imageFolder' in parents");

    var directory = await getApplicationDocumentsDirectory();

    // download from google drive
    for (var file in achiveImageFiles.files!) {
      io.File mediaFile = io.File('${directory.path}/${file.name}');

      if (!await mediaFile.exists()) {
        List<int> dataStore = [];
        var media = (await driveApi.files.get(file.id!,
            acknowledgeAbuse: true,
            downloadOptions: drive.DownloadOptions.fullMedia)) as drive.Media;
        media.stream.listen((data) {
          dataStore.insertAll(dataStore.length, data);
        }, onDone: () {
          mediaFile.writeAsBytesSync(dataStore);
          result[file.name!] = Image.memory(Uint8List.fromList(dataStore));
          print('${file.name} downloaded');
        }, onError: (e) {
          print('image download failed : ${file.name}');
        });
      } else {
        result[file.name!] = Image.memory(mediaFile.readAsBytesSync());
        print('${file.name} is loaded');
      }
    }

    return result;
  }
}
