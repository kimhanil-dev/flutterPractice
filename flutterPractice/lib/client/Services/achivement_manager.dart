import 'package:acter_project/client/Services/google_drive_image_downloader.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:theater_publics/achivement.dart';
import 'package:flutter/material.dart';

class AchivementDataManger {
  final AchivementDB _achivementDB = AchivementDB();
  final Map<int, Image> _achivementImages = {};

  Future<void> loadDatas() async {
    var dotEnv = DotEnv(); 
    dotEnv.load(fileName: 'assets/.env');
    
    _achivementDB.loadData(dotEnv.env['GSHEETS_CREDENTIALS']!);
    final images = await GoogleDriveImageDownloader.downloadImages();

    // Organize images by id
    images.forEach((key, value) {
      var id = key.substring(0, key.length - 4);
      _achivementImages[int.parse(id)] = value;
    });
  }

  /// 이미지가 없을 경우 기본 이미지를 전달
  Image getImage(int id) {
    return _achivementImages[id] ?? _achivementImages[0]!;
  }

  AchivementData getData(int id) {
    return _achivementDB.getAchivementData(id)!;
  }
}
