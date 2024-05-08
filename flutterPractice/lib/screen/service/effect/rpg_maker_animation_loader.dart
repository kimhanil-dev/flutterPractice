
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:acter_project/client/Services/google_drive_image_downloader.dart';
import 'package:async/async.dart';

class Frame {
  Frame(this.spriteIndex, this.posX, this.posY, this.scale, this.rotation, this.isMirror, this.opacity, this.blendMode);
  
  final int spriteIndex;
  final int posX;
  final int posY;
  final int scale;
  final int rotation;
  final bool isMirror;
  final int opacity;
  final int blendMode;
}


class Animation {
  Animation(this.name,this.sprite1,  this.sprite2, this.frames);
  final String name; 
  final String sprite1;
  final String sprite2;
  final List<List<int>> frames;
  //frame
  //flash
  //soundeffect


}

class AnimationLoader {


  static void loadAnimation() {
    final gdDownloader = GoogleDriveDownloader<List<dynamic>>();
    gdDownloader.downloadFiles('18olrVdLQcdev7yBWPVn_Y1pP8goeNSQl', 'animation', loadAnimationFromJson);
  }

  static Resource<List<dynamic>> loadAnimationFromJson(String name, Uint8List bytes, File file){
    var data = jsonDecode(String.fromCharCodes(bytes));
    for (var e in data) {
      print(e);
    }

    return Resource<List<dynamic>>(name,data);
  }
}