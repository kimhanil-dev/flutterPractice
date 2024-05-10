import 'package:acter_project/screen/service/ui/command.dart' as command;
import 'package:flutter/material.dart';

import '../ui.dart';

abstract class CommandActor {
  command.CommandBinder cmdBinder = command.CommandBinder();

  /// 이곳에서 command function을 바인딩 합니다.
  void init();
  void runCommand(List<String> command) {
    cmdBinder.call(command[1], command.getRange(2, command.length).toList());
  }
}

class HpBar extends UI {
  HpBar(super.ticker, super.updater, this.posX, this.posY,
      {this.hpColor = Colors.red,
      this.hpUpdateTime = const Duration(microseconds: 500),
      this.hpUpdateCurve = Curves.ease});

  double maxHp = 100;
  double curHp = 100;
  double posX = 0;
  double posY = 0;
  Color hpColor;
  Duration hpUpdateTime;
  Curve hpUpdateCurve;

  late AnimationController controller;
  late Animation<double> animation;

  @override
  void init() {
    super.init();
    cmdBinder.bindFunctionToCommand('set', set);
    cmdBinder.bindFunctionToCommand('setPosition', setPosition);

    controller = AnimationController(duration: const Duration(seconds: 1),vsync: ticker);
    animation = Tween<double>(begin: maxHp, end: maxHp).animate(controller);
  }

  void setHp(double newHp) {
    animation = Tween<double>(begin: curHp, end: newHp).animate(controller);
    controller.reset();
    controller.forward();
    curHp = newHp;
  }

  void set(List<String> args) {
    maxHp = double.parse(args[0]);
    setHp(double.parse(args[1]));
  }

  void setPosition(List<String> args) {
    posX = double.parse(args[0]);
    posY = double.parse(args[1]);
  }

  @override
  Widget myUI(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.grey,
          width: 250,
          height: 50,
        ),
        AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Container(
              width: 250 * (animation.value / maxHp),
              height: 50,
              color: Colors.red,
            );
          },
        )
      ],
    );
  }
}
