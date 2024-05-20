import 'package:acter_project/screen/service/screen_effect_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../ui.dart';

abstract interface class CommandActor {
  /// 이곳에서 command function을 바인딩 합니다.
  void runCommand(List<String> command);
}

class UIMaker implements CommandActor {
  UIMaker(this.builder);
  final UIBuilder builder;

  @override
  void runCommand(List<String> command) {}
}

class UIHpBar extends UI {
  UIHpBar(
      {this.hpColor = Colors.red,
      this.hpUpdateTime = const Duration(microseconds: 500),
      this.hpUpdateCurve = Curves.ease,
      this.padding = const EdgeInsets.all(50),
      super.key});

  final Color hpColor;
  final Duration hpUpdateTime;
  final Curve hpUpdateCurve;
  final EdgeInsets padding;

  @override
  // TODO: implement isForward
  bool get isForward => false;

  @override
  State<UIHpBar> createState() => HPBarState();
}

class HPBarState extends State<UIHpBar> with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  double maxHp = 100;
  double curHp = 100;
  double _curHpBarScale = 1;
  double _prvHpBarScale = 1;

  @override
  void initState() {
    super.initState();

    widget.setCommand('set', set);

    controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    animation = Tween<double>(begin: maxHp, end: maxHp).animate(controller);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Container(
        child: Stack(
          children: [
            Container(
              color: Colors.grey,
              width: 250,
              height: 50,
            ),
            Container(
              width: 250,
              height: 50,
              color: Colors.red,
            )
          ],
        ),
      )
          // begin
          .animate()
          .fadeIn(duration: .35.seconds)
          .slide(begin: const Offset(0, .2))
          // set hp
          .animate(controller: controller, autoPlay: false)
          .scale(
              alignment: Alignment.centerLeft,
              duration: 2.seconds,
              begin: Offset(_prvHpBarScale, 1),
              end: Offset(_curHpBarScale, 1))
          .shake(duration: 2.seconds,hz: 50,offset: const Offset(0, 0),curve: Curves.bounceIn,rotation: 0.01 ),
    );
  }

  void setHp(double newHp) {
    setState(() {
      curHp = newHp;
      _prvHpBarScale = _curHpBarScale;
      _curHpBarScale = curHp / maxHp;

      controller.reset();
      controller.forward();
    });
  }

  void set(List<String> args) {
    setHp(double.parse(args[0]));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
