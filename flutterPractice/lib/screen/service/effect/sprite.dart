import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:acter_project/client/Services/google_drive_image_downloader.dart';
import 'package:spritewidget/spritewidget.dart';

class SpriteDownloader {
  static Future<Map<String, SpriteTexture>> download() async {
    final gdImageDownloader = GoogleDriveDownloader<String>();
    final paths = await gdImageDownloader.downloadFiles(
        '1COcAQQVI2h1XJOWQfXcpD86Vn8yuPjsU', 'sprites', spritePathLoader);

    var imageLoader = ImageMap();
    var images = await imageLoader.load(paths.values.toList());

    var keys = paths.keys.toList();
    Map<String,SpriteTexture> sprites = {};
    for(int i = 0; i < images.length; ++i) {
      sprites[keys[i].split('.')[0]] = SpriteTexture(images[i]);
    }

    return sprites;
  }

  static Resource<String> spritePathLoader(
      String name, Uint8List bytes, File file) {
    return Resource<String>(name, file.path);
  }
}

class MySprite {
  MySprite(this.source) {
    var spriteCount = source.size / 192;
    for (int y = 0; y < spriteCount.height; ++y) {
      for (int x = 0; x < spriteCount.width; ++x) {
        double xBias = x * 192;
        double yBias = y * 192;
        var rect = Rect.fromLTWH(xBias, yBias, 192, 192);
        sprites.add(source.textureFromRect(rect));
      }
    }
  }

  final SpriteTexture source;
  final List<SpriteTexture> sprites = [];

  SpriteTexture getSprite(int index) {
    return sprites[index];
  }
}
