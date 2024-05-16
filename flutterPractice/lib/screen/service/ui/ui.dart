import 'package:acter_project/screen/service/ui/command.dart' as command;
import 'package:acter_project/screen/service/ui/hp/hp_bar.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'ui_animation/ui_animation.dart';

class DynamicChild {
  Widget? child;
}

abstract class UI extends StatefulWidget implements CommandActor {
  /// isForward가 True 일때만 Child가 유효합니다.
  final command.CommandBinder cmdBinder = command.CommandBinder();

  UI({super.key});

  @override
  void runCommand(List<String> command) {
    cmdBinder.call(command[0], command.getRange(1, command.length).toList());
  }

  void setCommand(String command, Function(List<String> args) func) {
    cmdBinder.bindFunctionToCommand(command, func);
  }

  final List<UIAnimation> animations = [];
  void addUIAnimation(UIAnimation animation,
      {bool isAutoRemoved = false, Duration? duration, Function? updater}) {
    animations.add(animation);
    if (isAutoRemoved) {
      Future.delayed(duration!).then((value) {
        animations.remove(animation);
        updater?.call();
      });
    }
  }

  void removeUIAnimation(UIAnimation animation) {
    animations.remove(animation);
  }

  Widget getAnimatedWidget(Widget widget) {
    Widget animatedWidget = widget;
    for (var anim in animations.reversed) {
      animatedWidget = anim.animatedWidget(animatedWidget);
    }

    return animatedWidget;
  }

  @mustBeOverridden
  bool get isForward;
}

// abstract class UI implements CommandActor {
//   UI(this.ticker, this.updater);

//   final TickerProviderStateMixin ticker;
//   final Function() updater;
//   late UIBuilder uiBuilder;

//   command.CommandBinder cmdBinder = command.CommandBinder();

//   @override
//   void runCommand(List<String> command) {
//     cmdBinder.call(command[1], command.getRange(2, command.length).toList());
//   }

//   @override
//   void init(BuildContext context) {
//     cmdBinder.bindFunctionToCommand('visible', (p0) => visible());
//     cmdBinder.bindFunctionToCommand('invisible', (p0) => invisible());
//   }

//   List<UIAnimation> animations = [];
//   void addUIAnimation(UIAnimation animation,
//       {bool isAutoRemoved = false, Duration duration = const Duration()}) {
//     animations.add(animation);
//     if (isAutoRemoved) {
//       Future.delayed(duration).then((value) {
//         animations.remove(animation);
//         updater();
//       });
//     }
//   }

//   void removeUIAnimation(UIAnimation animation) {
//     animations.remove(animation);
//   }

//   void setWidgetBuilder(UIBuilder widgetBuilder) {
//     uiBuilder = widgetBuilder;
//   }

//   void visible() {
//     uiBuilder.addUI(this, isForward);
//   }

//   void invisible() {
//     uiBuilder.removeUI(this, isForward);
//   }

//   /// Forward UI일때만 child가 유효합니다.
//   Widget getUI(BuildContext context, {Widget? child}) {
//     Widget animatedWidget = myUI(context);
//     for (var anim in animations.reversed) {
//       animatedWidget = anim.animatedWidget(animatedWidget);
//     }

//     return animatedWidget;
//   }

//   /// Forward UI일때만 child가 유효합니다.
//   @mustBeOverridden
//   Widget myUI(BuildContext context, {Widget? child});

//   @mustBeOverridden
//   bool get isForward;
// }
