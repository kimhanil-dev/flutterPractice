import 'package:acter_project/client/curve/sin_curve.dart';
import 'package:acter_project/client/widgets/page/main_page.dart';
import 'package:acter_project/client/widgets/widget/corner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class NameContainer {
  final String name;

  NameContainer(this.name); 
}

class NamePage extends StatefulWidget {
  const NamePage({super.key});

  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> with TickerProviderStateMixin {
  String name = '';
  late AnimationController controller;
  late BuildContext pageContext;
  bool isAlreadyNamed = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: 2.seconds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTextStyle(
        style: TextStyle(color: Theme.of(context).primaryColor),
        child: Stack(
          children: [
            const Corner(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '당신의 ',
                      style: TextStyle(
                          color: Theme.of(context).primaryColor, fontSize: 25),
                    ),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        onSubmitted: (value) {
                          setState(() {
                            name = value;
                          });
                          Future.delayed(500.ms)
                              .then((value) => controller.forward());
                        },
                        style: TextStyle(
                            fontSize: 25,
                            color: Theme.of(context).indicatorColor),
                        decoration: InputDecoration(
                            hintText: '이름',
                            hintStyle: TextStyle(
                                fontSize: 25,
                                color: Theme.of(context).indicatorColor)),
                        textAlign: TextAlign.center,
                        cursorWidth: 5,
                        onChanged: (value) {
                          name = value;
                        },
                      )
                          .animate(
                            onPlay: (controller) => controller.repeat(),
                          )
                          .fadeIn(duration: 3.seconds, curve: SinCurve()),
                    ),
                    Text(
                      '을 입력해주세요',
                      style: TextStyle(
                          color: Theme.of(context).primaryColor, fontSize: 25),
                    )
                  ],
                ).animate(controller: controller, autoPlay: false).swap(
                  builder: (context, child) {
                    return Center(
                            child: Column(
                      children: [
                        Text(
                          '환영합니다',
                          style: TextStyle(
                              fontSize: 25,
                              color: Theme.of(context).indicatorColor),
                        ),
                        const Gap(20),
                        Text(
                          '$name 님',
                          style: TextStyle(
                              fontSize: 25,
                              color: Theme.of(context).indicatorColor),
                        ),
                      ],
                    ))
                        .animate(onComplete: (controller) {
                          route();
                        })
                        .slideY(
                            begin: 0.5, duration: 1.seconds, curve: Curves.ease)
                        .fadeIn(duration: 1.seconds)
                        .then(duration: 3.seconds)
                        .fadeOut(duration: 1.seconds, curve: Curves.ease)
                        .slideY(
                            duration: 1.seconds, end: 0.5, curve: Curves.ease);
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void route() {
    Navigator.of(context,rootNavigator: true).push(
      MaterialPageRoute(
      builder: (_) => Provider<NameContainer>(create: (_) => NameContainer(name),child: const MainPage()),
    ));
  }
}
