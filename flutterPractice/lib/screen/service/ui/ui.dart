import 'package:acter_project/screen/service/screen_effect_manager.dart';
import 'package:acter_project/screen/service/ui/hp/hp_bar.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'ui_animation/ui_animation.dart';

abstract class UI extends CommandActor {
  UI(this.ticker, this.updater) {
    init();
  }

  @override
  @mustCallSuper
  void init() {
    cmdBinder.bindFunctionToCommand('visible', (p0) => visible());
    cmdBinder.bindFunctionToCommand('invisible', (p0) => invisible());
  }

  late Function() updater;
  late TickerProviderStateMixin ticker;
  late UIBuilder _uiBuilder;
  List<UIAnimation> animations = [];
  void addUIAnimation(UIAnimation animation, {bool isAutoRemoved = false, Duration duration = const Duration()}) {
    animations.add(animation);
    if(isAutoRemoved) {
      Future.delayed(duration).then((value){
        animations.remove(animation);
        updater();
      });
    }
  }

  void removeUIAnimation(UIAnimation animation) {
    animations.remove(animation);
  }

  void setWidgetBuilder(UIBuilder widgetBuilder) {
    _uiBuilder = widgetBuilder;
  }

  void visible() {
    _uiBuilder.addUI(this);
  }

  void invisible() {
    _uiBuilder.removeUI(this);
  }

  Widget getUI(BuildContext context) {
    Widget animatedWidget = myUI(context);
    for (var anim in animations.reversed) {
      animatedWidget = anim.animatedWidget(animatedWidget);
    }

    return animatedWidget;
  }

  @mustBeOverridden
  Widget myUI(BuildContext context);
}
