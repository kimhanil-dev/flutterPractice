import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const Scaffold(
        body: Center(
          child: StartPage(),
        ),
      ),
    );
  }
}

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.all(50.0),
          child: Text(
            '어느날 갑자기 용사가 되어 마왕을 무찌르게 된 \n한 소년의 이야기',
            textAlign: TextAlign.center,
          ),
        ),
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(_createRoute());
            },
            child: const Text('Press any key to start !')),
      ],
    );
  }
}

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const MainPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child;
    },
  );
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(_createRouteSelectPage());
                },
                child: const Text('선택')),
            ElevatedButton(onPressed: () {}, child: const Text('기록')),
          ],
        ),
      ),
    );
  }
}

Route _createRouteSelectPage() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        const WaitConnectingPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child;
    },
  );
}

class WaitConnectingPage extends StatefulWidget {
  const WaitConnectingPage({super.key});

  @override
  State<WaitConnectingPage> createState() => _WaitConnectingPageState();
}

class _WaitConnectingPageState extends State<WaitConnectingPage> {
  final serverComunicator = Comunicator();
  Widget currentWidget = const Scaffold(
    body: Center(
      child: Column(
        children: [
          Text('당신의 의지가 세계와 연결되는 중 입니다.'),
        ],
      ),
    ),
  );

  @override
  void initState() {
    serverComunicator.tryToConnectServer();

    // update widget state
    serverComunicator.bindOnConnectServerCallback(
      () {
        setState(() {
          currentWidget = const Scaffold(
            body: Center(
              child: Column(
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
                    children: [
                      Text('세계가 시작되기를 기다리는 중 입니다.'),
                    ],
                  ),
                ),
              );
            });
          },
        );
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return currentWidget;
  }
}

class Comunicator {
  Comunicator({this.serverIp = 'localhost', this.serverPort = 55555});

  final String serverIp;
  final int serverPort;

  Socket? _server;
  Function()? _onConnectServer;
  Function()? _onGameStart;

  bool bindOnConnectServerCallback(Function() callback) {
    if (_onConnectServer != null) {
      return false;
    } else {
      _onConnectServer = callback;
      return true;
    }
  }

  bool bindOnGameStartCallback(Function() callback) {
    if (_onGameStart != null) {
      return false;
    } else {
      _onGameStart = callback;
      return true;
    }
  }

  // try to connect to server
  void tryToConnectServer() {
    Socket.connect(serverIp, serverPort).then(
      (socket) {
        _server = socket;
        _server!.listen((data) => _listen).onError((error) => _onError(error));

        if (_onConnectServer != null) {
          _onConnectServer!();
        }

        print('Connection from'
            '${_server!.remoteAddress.address}:${_server!.remotePort}');
      },
    ).onError(
      (error, stackTrace) {
        print(error.toString());
      },
    );
  }

  // error control
  void _onError(error) {
    print(error.toString());
  }

  // listen for events from the server and process
  void _listen(Uint8List data) async {
    final message = String.fromCharCodes(data);
    print('Server: $message');

    if (message == 'theater_start') {
      _onGameStart!();
    }
  }

  // send message to connected server
  void _write(String message) {
    _server!.write(message);
    print('Client: $message');
  }
}
