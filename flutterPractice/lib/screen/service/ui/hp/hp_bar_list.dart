import 'package:acter_project/screen/service/ui/hp/hp_bar.dart';
import 'package:acter_project/screen/service/ui/ui_animation/ui_animation_position.dart';
import 'package:flutter/material.dart';

import '../ui.dart';

// set(int ,double), add(count)
class UIHPBarList extends UI {
  UIHPBarList({super.key});

  @override
  bool get isForward => false;

  @override
  State<UIHPBarList> createState() => _HPBarListState();
}

class _HPBarListState extends State<UIHPBarList> {
  final List<UIHpBar> hpBars = [];
  UIHpBar? bossHpBar;
  final double uiGap = 100;
  final Duration hpUpdateTime = const Duration(seconds: 500);

  @override
  void initState() {
    super.initState();

    widget.setCommand('set', setHp);
    widget.setCommand('setBoss', setBossHp);
    widget.setCommand('addBoss', addBossHPBar);
    widget.setCommand('add', addHPBar);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> hps = [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [...hpBars.map((e) => e)],
      )
    ];
    if (bossHpBar != null) {
      hps.add(bossHpBar!);
    }

    return Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [...hps],
        ));
  }

  void setHp(List<String> args) {
    int hpIndex = int.parse(args[0]);
    double newHp = double.parse(args[1]);

    hpBars[hpIndex].runCommand(['set', newHp.toString()]);
  }

  void setBossHp(List<String> args) {
    double newHp = double.parse(args[0]);
    bossHpBar?.runCommand(['set', newHp.toString()]);
  }

  void addBossHPBar(List<String> args) {
    setState(() {
      bossHpBar = UIHpBar(
        hpUpdateTime: hpUpdateTime,
      );
    });
  }

  void addHPBar(List<String> args) {
    int count = int.parse(args[0]);
    for (int i = 0; i < count; ++i) {
      var hpBar = UIHpBar(hpUpdateTime: hpUpdateTime);
      setState(() {
        hpBars.add(hpBar);
      });
    }
  }
}
