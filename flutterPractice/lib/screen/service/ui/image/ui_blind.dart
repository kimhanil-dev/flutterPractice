import 'package:acter_project/screen/service/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// set(image, posX, posY)
class UIBlind extends UI {
  UIBlind({super.key});

  @override
  bool get isForward => false;

  @override
  State<UIBlind> createState() => UIBlindState();
}

class UIBlindState extends State<UIBlind> with TickerProviderStateMixin {
  late AnimationController fadeController;
  double startAlpha = 0.0;
  double endAlpha = 1.0;
  double duration = 500; //ms

  @override
  void initState() {
    super.initState();

    // add command
    // from, to , time/ms
    widget.setCommand('Set', set);

    fadeController = AnimationController(
      vsync: this,
      duration: 2000.ms,
      value: 0,
    );
  }

  void set(List<String> args) {
    setState(() {
      startAlpha = double.parse(args[0]) / 100;
      endAlpha = double.parse(args[1]) / 100;
      duration = double.parse(args[2]);

      fadeController.reset();
      fadeController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.black)
        .animate(controller: fadeController, autoPlay: false)
        .fade(begin: startAlpha, end: endAlpha, duration: duration.ms);
  }

  @override
  void dispose() {
    fadeController.dispose();
    super.dispose();
  }
}
