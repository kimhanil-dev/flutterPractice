import 'package:acter_project/screen/service/screen_effect_manager.dart';
import 'package:acter_project/screen/service/ui/hp/hp_bar.dart';
import 'package:flutter/material.dart';

import 'ui.dart';

class TextUI extends UI {

  TextUI(super.controller, super.updater,this.text,this.position);
  final String text;
  final Offset position;
  late final UIBuilder builder;
  
  @override
  Widget myUI(BuildContext context) {
    // TODO: implement myUI
    throw UnimplementedError();
  }
}