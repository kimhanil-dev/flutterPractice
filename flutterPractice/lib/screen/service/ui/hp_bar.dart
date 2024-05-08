import 'package:acter_project/screen/service/screen_effect_manager.dart';
import 'package:acter_project/screen/service/ui/command.dart' as command;
import 'package:flutter/material.dart';

abstract class CommandActor {
  command.CommandBinder cmdBinder = command.CommandBinder();

  /// 이곳에서 command function을 바인딩 합니다.
  void init();
  void runCommand(List<String> command) {
    cmdBinder.call(command[1], command.getRange(2, command.length).toList());
  }
}

abstract interface class UI {
  void setWidgetBuilder(UIBuilder widgetBuilder);
  Widget getUI();
}

class HpBar extends CommandActor implements UI {
  HpBar() {
    init();
  }
  late UIBuilder _uiBuilder;

  double maxHp = 0;
  double curHp = 0;
  double posX = 0;
  double posY = 0;

  @override
  void init() {
    cmdBinder.bindFunctionToCommand('visible', setVisible);
    cmdBinder.bindFunctionToCommand('invisible', setInvisible);
    cmdBinder.bindFunctionToCommand('set', set);
    cmdBinder.bindFunctionToCommand('setPosition', setPosition);
  }

  void set(List<String> args) {
    maxHp = double.parse(args[0]);
    curHp = double.parse(args[1]);
  }

  void setPosition(List<String> args) {
    posX = double.parse(args[0]);
    posY = double.parse(args[1]);
  }

  @override
  Widget getUI() {
    return Positioned(
      left: posX,
      top: posY,
      child: Stack(
        children: [
          Container(
            color: Colors.grey,
            width: 250,
            height: 50,
          ),
          AnimatedContainer(
            width: 250 * (curHp / maxHp),
            height: 50,
            duration: const Duration(seconds: 1),
            curve: Curves.ease,
            color: Colors.red,
          )
        ],
      ),
    );
  }

  void setInvisible(List<String> args) {
    _uiBuilder.removeUI(this);
  }

  void setVisible(List<String> args) {
    _uiBuilder.addUI(this);
  }

  @override
  void setWidgetBuilder(UIBuilder widgetBuilder) {
    _uiBuilder = widgetBuilder;
  }
}
