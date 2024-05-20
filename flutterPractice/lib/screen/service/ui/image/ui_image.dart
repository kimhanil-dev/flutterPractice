import 'dart:ui';

import 'package:acter_project/screen/service/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:provider/provider.dart';

import '../../data_manager.dart';

/// set(image, posX, posY)
class UIImage extends UI {
  UIImage({super.key});

  @override
  bool get isForward => false;

  @override
  State<UIImage> createState() => UIWinState();
}

class UIWinState extends State<UIImage> with TickerProviderStateMixin {
  late AnimationController controller;
  Image? image;
  Image? nextImage;
  double posX = 0;
  double posY = 0;

  @override
  void initState() {
    super.initState();

    // add command
    widget.setCommand('set', set);

    // add animations
    controller = AnimationController(
      vsync: this,
      duration: 2000.ms,
      value: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: image ?? Container(),);
  }

  void set(List<String> args) {
    setState(() {
      if (args.isEmpty) {
        image = null;
        return;
      }

      image = context.read<DataManager>().bgImages[args[0]];
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
