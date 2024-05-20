import 'dart:io' as io;
import 'dart:io';

import 'package:audioplayers/audioplayers.dart' as audio;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path_provider/path_provider.dart';
import 'package:googleapis_auth/auth_io.dart';

class Resource<E> {
  Resource(this.name, this.data);
  String name;
  E data;
}

class GoogleDriveDownloader<E> {
  Future<Map<String, E>> downloadFiles(
      String googleFolderId,
      String saveFolder,
      Resource<E> Function(String name, Uint8List bytes, io.File file)
          loader) async {
    // connect to google `Drive Api`;
    var client = await clientViaServiceAccount(
      
        ServiceAccountCredentials.fromJson(await rootBundle
            .loadString('assets/api-key/google-drive-api-key.json')),
        [drive.DriveApi.driveReadonlyScope]);
    var driveApi = drive.DriveApi(client);

    // quary achivement image meta datas;
    var files = await driveApi.files.list(q: "'$googleFolderId' in parents",pageSize: 1000);

    // save directory
    final directory =
        '${(await getApplicationDocumentsDirectory()).path}\\$saveFolder';

    List<Future<Resource<E>>> fileLoaders = [];
    for (var file in files.files!) {
      fileLoaders.add(_downloadFile(driveApi, file, directory, loader));
    }

    var resources = await Future.wait(fileLoaders);
    Map<String, E> result = {};
    for (var resource in resources) {
      result[resource.name] = resource.data;
    }

    return result;
  }

  Future<Resource<E>> _downloadFile(
      drive.DriveApi driveApi,
      drive.File file,
      String directoryPath,
      Resource<E> Function(String name, Uint8List bytes, io.File file)
          loader) async {
    List<int> dataStore = [];
    var media = (await driveApi.files.get(file.id!,
        acknowledgeAbuse: true,
        downloadOptions: drive.DownloadOptions.fullMedia)) as drive.Media;

    io.File mediaFile = io.File('$directoryPath\\${file.name}');

    var streamData = await media.stream.toList();
    for (var byte in streamData) {
      dataStore.addAll(byte);
    }

    if (!await mediaFile.exists()) {
      await Directory(directoryPath).create(recursive: true);
      mediaFile.writeAsBytesSync(dataStore);
      return loader(file.name!, Uint8List.fromList(dataStore), mediaFile);
    }

    return loader(
        file.name!, Uint8List.fromList(mediaFile.readAsBytesSync()), mediaFile);
  }

  static Resource<audio.Source> audioLoader(
      String name, Uint8List bytes, io.File file) {
    return Resource<audio.Source>(name.split('.')[0], audio.DeviceFileSource(file.path));
  }

  static Resource<Image> imageLoader(
      String name, Uint8List bytes, io.File file) {
    return Resource<Image>(name, Image.memory(bytes));
  }
}
