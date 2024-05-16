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
  final double uiGap = 100;
  final Duration hpUpdateTime = const Duration(seconds: 500);

  @override
  void initState() {
    super.initState();

    widget.setCommand('set', setHp);
    widget.setCommand('add', addHPBar);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: ListView(
        padding: const EdgeInsets.all(10),
        children: [...hpBars.map((e) => e)],
      ),
    );
  }

  void setHp(List<String> args) {
    int hpIndex = int.parse(args[0]);
    double newHp = double.parse(args[1]);

    hpBars[hpIndex].runCommand(['set', newHp.toString()]);
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
