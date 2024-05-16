import 'package:flutter/material.dart';

import 'corner_image.dart';

class Corner extends StatelessWidget {
  const Corner({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
            child: CornerImage(
          rotate: 90,
        )),
        Positioned(
          right: 0,
          top: 0,
            child: CornerImage(
          rotate: 180,
        )),
        Positioned(
          right: 0,
          bottom: 0,
            child: CornerImage(
          rotate: 270,
        )),
        Positioned(
          left: 0,
          bottom: 0,
            child: CornerImage(
          rotate: 360,
        )),
      ],
    );
  }
}
