import 'package:flutter/material.dart';

abstract class UIAnimation {
  Widget animatedWidget(Widget widget, {AnimationController? controller});
}
