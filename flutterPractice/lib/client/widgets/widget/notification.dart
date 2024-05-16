import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import 'framed_image.dart';

class NotificationWidget extends StatefulWidget {
  const NotificationWidget(
      {super.key,
      required this.image,
      required this.text,
      required this.onFadeOut});
  final Image image;
  final String text;
  final Function(NotificationWidget) onFadeOut;

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FramedImage(
          width: 150,
          height: 150,
          image: widget.image,
        )
            .animate(onComplete: (controller) => widget.onFadeOut(widget))
            .slideY(duration: .5.seconds, begin: -1, end: 0)
            .fadeIn(duration: .5.seconds, begin: 0.0)
            .then(delay: 1.seconds)
            .fadeOut(duration: 300.ms)
            .slideY(duration: 300.ms, begin: 0, end: -1),
        const Gap(25),
        Text(widget.text,
                style: TextStyle(
                    fontSize: 15, color: Theme.of(context).primaryColor))
            .animate(onComplete: (controller) => widget.onFadeOut(widget))
            .slideX(duration: .5.seconds, begin: -1, end: 0)
            .fadeIn(duration: .5.seconds, begin: 0.0)
            .then(delay: 1.seconds)
            .fadeOut(duration: 300.ms)
            .slideX(duration: 300.ms, begin: 0, end: 1)
      ],
    );
  }
}
