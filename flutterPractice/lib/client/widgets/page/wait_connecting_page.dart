import 'dart:math';

import 'package:acter_project/client/Services/client.dart';
import 'package:acter_project/client/widgets/page/name_page.dart';
import 'package:acter_project/client/widgets/page/play_page.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:theater_publics/public.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:global_configuration/global_configuration.dart' as config;

class WaitConnectingPage extends StatefulWidget {
  const WaitConnectingPage({super.key});

  @override
  State<WaitConnectingPage> createState() => _WaitConnectingPageState();
}

class _WaitConnectingPageState extends State<WaitConnectingPage> {
  late Client client;
  late NameContainer name;
  String loadingText = '당신의 의지가 세계와 연결되는 중 입니다.';

  @override
  void initState() {
    super.initState();

    client = context.read<Client>();
    name = context.read<NameContainer>();

    initClient();
  }

  void initClient() {
    // connect to server
    config.GlobalConfiguration().loadFromAsset('config').then((value) {
      var serverIp = config.GlobalConfiguration().getValue<String>('server-ip');
      var serverPort =
          config.GlobalConfiguration().getValue<int>('server-port');
      client.connectToServer(serverIp, serverPort, (isConnected) {
        if (isConnected) {
          setState(() => loadingText = '연결 성공');

          // 이름 전달
          client.sendMessage(
              message: MessageType.sendName, object: StringData(name.name));

          Future.delayed(3.seconds).then(
              (value) => setState(() => loadingText = '세계가 시작되기를 기다리는 중 입니다.'));
        } else {
          // TODO: 연결 실패
        }
      });

      // waiting server start
      client.addMessageListener((message) {
        if (MessageType.onTheaterStarted == message.messageType) {
          setState(() => loadingText = '세계가 시작되었습니다.');
          Future.delayed(3.seconds).then((value) => Navigator.of(context)
              .pushReplacement(
                  MaterialPageRoute(builder: (context) => const PlayPage())));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: 50,
                          height: 50,
                          child: SvgPicture.asset(
                            'assets/images/ui/DecorShape1.svg',
                            colorFilter: ColorFilter.mode(
                                Theme.of(context).colorScheme.primary,
                                BlendMode.srcIn),
                          )
                              .animate(
                                  onPlay: (controller) => controller.repeat())
                              .rotate(
                                  end: 1,
                                  duration: getRandomDouble().seconds,
                                  curve: Curves.easeInExpo)),
                      const Gap(2),
                      SizedBox(
                          width: 50,
                          height: 50,
                          child: SvgPicture.asset(
                                  'assets/images/ui/DecorShape2.svg',
                                  colorFilter: ColorFilter.mode(
                                      Theme.of(context).colorScheme.primary,
                                      BlendMode.srcIn))
                              .animate(
                                  onPlay: (controller) => controller.repeat())
                              .rotate(
                                  end: 1,
                                  duration: getRandomDouble().seconds,
                                  curve: Curves.easeInExpo)),
                      const Gap(2),
                      SizedBox(
                          width: 50,
                          height: 50,
                          child: SvgPicture.asset(
                                  'assets/images/ui/DecorShape3.svg',
                                  colorFilter: ColorFilter.mode(
                                      Theme.of(context).colorScheme.primary,
                                      BlendMode.srcIn))
                              .animate(
                                  onPlay: (controller) => controller.repeat())
                              .rotate(
                                  end: 1,
                                  duration: getRandomDouble().seconds,
                                  curve: Curves.easeInExpo)),
                      const Gap(2),
                      SizedBox(
                          width: 50,
                          height: 50,
                          child: SvgPicture.asset(
                                  'assets/images/ui/DecorShape4.svg',
                                  colorFilter: ColorFilter.mode(
                                      Theme.of(context).colorScheme.primary,
                                      BlendMode.srcIn))
                              .animate(
                                  onPlay: (controller) => controller.repeat())
                              .rotate(
                                  end: 1,
                                  duration: getRandomDouble().seconds,
                                  curve: Curves.easeInExpo)),
                      const Gap(2),
                      SizedBox(
                          width: 50,
                          height: 50,
                          child: SvgPicture.asset(
                                  'assets/images/ui/DecorShape5.svg',
                                  colorFilter: ColorFilter.mode(
                                      Theme.of(context).colorScheme.primary,
                                      BlendMode.srcIn))
                              .animate(
                                  onPlay: (controller) => controller.repeat())
                              .rotate(
                                  end: 1,
                                  duration: getRandomDouble().seconds,
                                  curve: Curves.easeInExpo))
                    ],
                  ),
                  const Gap(30),
                  Text(
                    loadingText,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 15),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  double min = 3.0;
  double max = 7.0;
  double getRandomDouble() {
    return (Random().nextDouble() * max) + min;
  }
}
