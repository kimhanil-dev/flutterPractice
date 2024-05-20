import 'package:acter_project/client/curve/sin_curve.dart';
import 'package:acter_project/client/widgets/page/name_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          controller.forward();
          HapticFeedback.mediumImpact();
        },
        child: DefaultTextStyle(
          style: const TextStyle(color: Color.fromARGB(255, 255, 219, 163)),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(children: [
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: SvgPicture.asset(
                      'assets/Untitled-1.svg',
                      fit: BoxFit.scaleDown,
                      colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.primary,
                          BlendMode.srcIn),
                    )
                        .animate(
                          onPlay: (controller) => controller.repeat(),
                        )
                        .blur(
                            duration: 3.seconds,
                            curve: SinCurve(),
                            begin: const Offset(4, 4),
                            end: const Offset(12, 12))
                        .animate(
                          controller: controller,
                          autoPlay: false,
                          onComplete: (controller) {
                            Navigator.of(context)
                                .pushReplacement(MaterialPageRoute(
                              builder: (context) => const NamePage(),
                            ));
                          },
                        )
                        .scale(
                            end: const Offset(300, 300), duration: 5.seconds),
                  ),
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: SvgPicture.asset(
                      'assets/Untitled-1.svg',
                      fit: BoxFit.scaleDown,
                      colorFilter: const ColorFilter.mode(
                          Color.fromARGB(255, 255, 218, 154), BlendMode.srcIn),
                    ),
                  ).animate(
                          controller: controller,
                          autoPlay: false,
                        )
                        .scale(
                            end: const Offset(300, 300), duration: 5.seconds),
                ]),
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
                      begin: const Offset(1.2, 1.2),
                    )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
