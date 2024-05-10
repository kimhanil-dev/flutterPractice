import 'package:acter_project/screen/service/ui/ui_animation/ui_animation.dart';
import 'package:flutter/material.dart';

/// position pivot LT
class UIAnimatedPosition implements UIAnimation {
  UIAnimatedPosition(
      this.duration, this.startX, this.startY, this.destX, this.destY,
      {this.curve = Curves.ease});
  final Duration duration;
  final double destX;
  final double destY;
  final double startX;
  final double startY;
  final Curve curve;

  @override
  Widget animatedWidget(Widget widget, {AnimationController? controller}) {
    return TweenAnimationBuilder(
      duration: duration,
      curve: curve,
      tween: Tween<Offset>(
          begin: Offset(startX, startY), end: Offset(destX, destY)),
      builder: (BuildContext context, Offset position, Widget? child) {
        return Positioned(left: position.dx, top: position.dy, child: widget);
      },
    );
  }
}
