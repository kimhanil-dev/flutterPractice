import 'dart:io';

import 'package:acter_project/screen/service/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// set(image, posX, posY)
class UIStart extends UI {
  UIStart({super.key});

  @override
  bool get isForward => false;

  @override
  State<UIStart> createState() => UIStartState();
}

class UIStartState extends State<UIStart>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        color: Colors.black,
        child: Text('Press Action To Start'));
  }

}
