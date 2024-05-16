

import 'package:acter_project/screen/service/data_manager.dart';
import 'package:acter_project/screen/service/ui/ui_animation/ui_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class UIAnimationTransition implements UIAnimation {
  UIAnimationTransition(this.shader, this.dataManager);
  final FragmentShader shader;
  final DataManager dataManager;

  @override
  Widget animatedWidget(Widget widget, {AnimationController? controller}) {
    return AnimatedSampler((image, size, canvas) {
      // transition.frag 
      // uSize
      shader.setFloat(0, size.width);
      shader.setFloat(1, size.height);
      // uProgress
      shader.setFloat(2, size.height);
      // uImage
      shader.setImageSampler(0, image);
      // uFade
      shader.setImageSampler(1, dataManager.fades['fade1']!);

    }, child: widget);
  }

}