import 'package:acter_project/screen/service/ui/ui_animation/ui_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';
import 'package:shake_animation_widget/shake_animation_widget.dart';

class UIAnimationShake extends UIAnimation {
  UIAnimationShake(this.shake, this.duration);
  final ShakeConstant shake;
  final Duration duration;

  @override
  Widget animatedWidget(Widget widget, {AnimationController? controller}) {
    return ShakeAnimationWidget(child: widget,); 
  }
}
