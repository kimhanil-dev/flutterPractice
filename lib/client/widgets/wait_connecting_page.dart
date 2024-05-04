import 'package:acter_project/client/Services/client.dart';
import 'package:acter_project/client/widgets/play_page.dart';
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
  Widget currentWidget = const Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('당신의 의지가 세계와 연결되는 중 입니다.'),
        ],
      ),
    ),
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    client = context.read<Client>();
    initClient();
  }

  void initClient() {
    config.GlobalConfiguration().loadFromAsset('config').then((value) {
      var serverIp = config.GlobalConfiguration().getValue<String>('server-ip');
      var serverPort = config.GlobalConfiguration().getValue<int>('server-port');
      client.connectToServer(serverIp, serverPort, (isConnected) {
        if (isConnected) {
          onConnectServerCallback();
        }
      });
      client.addMessageListener((message) {
        if (MessageType.onTheaterStarted == message.messageType) {
          onTheaterStartCallback();
        }
      });
    });
  }

  void onConnectServerCallback() {
    setState(() {
      currentWidget = const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('연결 완료'),
            ],
          ),
        ),
      );
    });

    Future<void>.microtask(() {
      const Duration(seconds: 5);
    }).then(
      (value) {
        setState(() {
          currentWidget = const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('세계가 시작되기를 기다리는 중 입니다.'),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void onTheaterStartCallback() {
    setState(() {
      currentWidget = const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('세계가 시작되었습니다.'),
            ],
          ),
        ),
      );
    });

    Future<void>.microtask(() {
      const Duration(seconds: 5);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const PlayPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return currentWidget;
  }
}
