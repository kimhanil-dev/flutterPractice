import 'package:acter_project/client/curve/sin_curve.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'routing_page.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const MainPage(),
      )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 300,
            height: 300,
            child: SvgPicture.asset(
              'assets/Untitled-1.svg',
              fit: BoxFit.scaleDown,
              colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primary, BlendMode.srcIn),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(50.0),
            child: Text(
              '어느날 갑자기 용사가 되어 마왕을 무찌르게 된 \n한 소년의 이야기',
              textAlign: TextAlign.center,
            ),
          ),
          const Text('PRESS ANY KEY TO START')
              .animate(
                onPlay: (controller) => controller.repeat(),
              )
              .scale(
                  duration: 3.seconds,
                  curve: SinCurve(),
                  begin: const Offset(0.8, 0.8)),
        ],
      ),
    );
  }
}
