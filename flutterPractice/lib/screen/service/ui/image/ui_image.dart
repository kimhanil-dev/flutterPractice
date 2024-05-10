import 'package:acter_project/screen/service/ui/ui.dart';
import 'package:flutter/material.dart';

/// set(image, posX, posY)
class UIImage extends UI {
  UIImage(super.ticker, super.updater, this.images, this.posX, this.posY);
  late Map<String, Image> images;
  late Image image;
  late double posX;
  late double posY;

  @override
  void init() {
    super.init();
    cmdBinder.bindFunctionToCommand('set', set);
  }

  void set(List<String> args) {
    image = images[args[0]]!;
    posX = double.parse(args[1]);
    posX = double.parse(args[2]);
  }

  @override
  Widget myUI(BuildContext context) {
    return Positioned(left: posX, top: posY, child: image);
  }
}
