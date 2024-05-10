import 'package:acter_project/screen/service/ui/hp/hp_bar.dart';
import 'package:acter_project/screen/service/ui/ui_animation/ui_animation_position.dart';
import 'package:acter_project/screen/service/ui/ui_animation/ui_animation_shake.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';

import '../ui.dart';

// set(int ,double), add(count)
class HPBarList extends UI {
  HPBarList(super.controller, super.updater);
  List<HpBar> hpBars = [];
  double uiGap = 100;
  Duration hpUpdateTime = const Duration(seconds: 500);

  @override
  void init() {
    super.init();
    cmdBinder.bindFunctionToCommand('set', setHp);
    cmdBinder.bindFunctionToCommand('add', addHpBar);
  }

  void setHp(List<String> args) {
    int hpIndex = int.parse(args[0]);
    double newHp = double.parse(args[1]);

    if (newHp < hpBars[hpIndex].curHp) {
      hpBars[hpIndex]
          .addUIAnimation(UIAnimationShake(ShakeHardConstant1(), hpUpdateTime), isAutoRemoved: true, duration: const Duration(seconds: 1));
    }

    hpBars[hpIndex].setHp(newHp);
  }

  void addHpBar(List<String> args) {
    int count = int.parse(args[0]);
    for (int i = 0; i < count; ++i) {
      var hpBar = HpBar(ticker,updater, 0, 0, hpUpdateTime: hpUpdateTime);
      hpBar.addUIAnimation(UIAnimatedPosition(const Duration(seconds: 1), 0,
          1300, 0, uiGap * (hpBars.length.toDouble())));
      hpBars.add(hpBar);
    }
  }

  @override
  void invisible() {
    super.invisible();
    hpBars.clear();
  }

  @override
  Widget myUI(BuildContext context) {
    return Stack(
      children: [...hpBars.map((e) => e.getUI(context))],
    );
  }
}
