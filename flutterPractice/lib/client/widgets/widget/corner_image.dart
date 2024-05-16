import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CornerImage extends StatelessWidget {
  const CornerImage({
    required this.rotate,
    super.key,
  });

  final double rotate;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 70,
        height: 70,
        child: Transform.rotate(
          angle: rotate * math.pi / 180,
          child: SvgPicture.asset(
            'assets/images/ui/Corner1.svg',
            colorFilter: ColorFilter.mode(
                Theme.of(context).primaryColor, BlendMode.srcIn),
          ),
        ));
  }
}
