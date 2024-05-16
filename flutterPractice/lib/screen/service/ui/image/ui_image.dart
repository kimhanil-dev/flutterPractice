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
  State<UIImage> createState() => UIImageState();
}

class UIImageState extends State<UIImage> with TickerProviderStateMixin {
  late FragmentShader shader;
  late AnimationController controller;
  late Effect shaderEffect;
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
    shader = context.read<FragmentShader>();
    shader.setImageSampler(1, context.read<DataManager>().fades['fade3']!);

    controller = AnimationController(
      vsync: this,
      duration: 2000.ms,
      value: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: image ?? Image.asset('assets/black.png'))
        .animate(controller: controller, onComplete: fadeComplite)
        .shader(
            duration: 2.seconds,
            shader: shader,
            update: (details) {
              var x = MediaQuery.of(context).size.width;
              var y = MediaQuery.of(context).size.height;
              details.shader.setFloat(0, x);
              details.shader.setFloat(1, y);
              details.shader.setFloat(2, (details.value * 2) - 1);
              details.shader.setFloat(3, 1.0);
              details.shader.setImageSampler(0, details.image);
            });
  }

  void fadeComplite(AnimationController controller) {
    setState(() {
      if (nextImage != null) {
        image = Image(image: nextImage!.image, fit: BoxFit.fill);
      }
    });
    controller.reverse();
  }

  void set(List<String> args) {
    setState(() {
      nextImage = context.read<DataManager>().bgImages[args[0]]!;
      posX = double.parse(args[1]);
      posX = double.parse(args[2]);

      controller.reset();
      controller.forward();
    });
  }
}
