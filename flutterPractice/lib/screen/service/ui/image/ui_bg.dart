import 'dart:ui';

import 'package:acter_project/screen/service/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:provider/provider.dart';

import '../../data_manager.dart';

/// set(image, posX, posY)
class UIBG extends UI {
  UIBG({super.key});

  @override
  bool get isForward => false;

  @override
  State<UIBG> createState() => UIBGState();
}

class UIBGState extends State<UIBG> with TickerProviderStateMixin {
  late FragmentShader shader;
  late Effect shaderEffect;

  late AnimationController fadeController;

  Image? image;
  Image? nextImage;
  bool isReActivated = false;

  @override
  void initState() {
    super.initState();

    // add command
    widget.setCommand('FO', fadeOut);
    widget.setCommand('FI', fadeIn);

    // add animations
    shader = context.read<FragmentShader>();
    shader.setImageSampler(1, context.read<DataManager>().fades['fade3']!);

    fadeController = AnimationController(
      vsync: this,
      duration: 2000.ms,
      value: 0,
    );
  }

  void fadeOut(List<String> args) {
    setState(() {
      fadeController.reset();
      fadeController.value = 0;
      fadeController.forward();

    });
  }

  void fadeIn(List<String> args) {
    setState(() {
      fadeController.reset();
      fadeController.value = 1;
      fadeController.reverse();

      image = Image(
        image: context.read<DataManager>().bgImages[args[0]]!.image,
        fit: BoxFit.fill,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: image ?? Image.asset('assets/black.png'))
        .animate(controller: fadeController, autoPlay: false)
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

  @override
  void dispose() {
    fadeController.dispose();
    super.dispose();
  }
}
