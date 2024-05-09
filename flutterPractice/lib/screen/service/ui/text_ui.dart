import 'package:acter_project/screen/service/effect/screen_effect.dart';
import 'package:acter_project/screen/service/screen_effect_manager.dart';
import 'package:acter_project/screen/service/ui/hp_bar.dart';
import 'package:flutter/src/widgets/framework.dart';

class TextUI extends CommandActor implements UI{
    

  @override
  Widget getUI() {
    // TODO: implement getUI
    throw UnimplementedError();
  }

  @override
  void init() {
    // TODO: implement init
    cmdBinder.bindFunctionToCommand('visible', setVisible);
    cmdBinder.bindFunctionToCommand('invisible', setVisible);
  }

  @override
  void setWidgetBuilder(UIBuilder widgetBuilder) {
    // TODO: implement setWidgetBuilder
  }

  void setVisible(List<String> args) {

  }

  void setInvisible(List<String> args) {

  }

}