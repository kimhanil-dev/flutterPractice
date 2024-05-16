import 'package:acter_project/screen/service/ui/hp/hp_bar.dart';
import 'package:acter_project/screen/service/ui/ui.dart';
import 'package:flutter/material.dart';

class UIText extends UI {
  UIText({super.key});

  @override
  bool get isForward => false;

  @override
  State<UIText> createState() => UITextState();
}

class UITextState extends State<UIText> with TickerProviderStateMixin {
  String text = '';
  double dx = 0.0;
  double dy = 0.0;

  @override
  void initState() {
    super.initState();
    widget.setCommand('set', set);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      child: Text(text),
    ); 
  }

  void set(List<String> args) {
    setState(() {
      text = args[0];
      dx = double.parse(args[1]);
      dy = double.parse(args[2]);
    });
  }
}
