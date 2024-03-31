import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
  late Communicator serverCommunicator;
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
    serverCommunicator =
        Communicator(onConnectServerCallback, onTheaterStartCallback);
    serverCommunicator.tryToConnectServer();
    super.initState();
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
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => SelectPage(serverCommunicator)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return currentWidget;
  }
}

// 유저들이 투표를 할 수 있는 페이지
class SelectPage extends StatefulWidget {
  const SelectPage(this.serverCommunicator, {super.key});
  final Communicator serverCommunicator;

  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ButtonWithMessage(widget.serverCommunicator,'스킵','skip'),
            const SizedBox(
              width: 20,
              height: 20,
            ),
            ButtonWithMessage(widget.serverCommunicator,'액션','action'),
          ],
        ),
      ),
    );
  }
}

// 버튼을 누르면 메세지가 띄워져 입력을 막는 위젯으로,
// buttonText는 UI로 보여질 텍스트
// 버튼을 누르면 message를 서버로 전송합니다.
class ButtonWithMessage extends StatefulWidget {
  const ButtonWithMessage(this.serverCommunicator, this.buttonText, this .message, {super.key});
  final Communicator serverCommunicator;
  final String buttonText;
  final String message;

  @override
  State<ButtonWithMessage> createState() => _ButtonWithMessageState();
}

class _ButtonWithMessageState extends State<ButtonWithMessage> {
  bool bIsButtonPressed = false;
  @override
  void initState() {
    widget.serverCommunicator.addMessageListener((message) {
      if(message == widget.message + '_complite') {
        setState(() {
          bIsButtonPressed = false;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: bIsButtonPressed
          ? const Card(
              child: Text('처리 중 입니다...'),
            )
          : ElevatedButton(
              onPressed: () {
                setState(() {
                  bIsButtonPressed = true;
                  widget.serverCommunicator.sendMessage(widget.message);
                });
              },
              child: Text(widget.buttonText)),
    );
  }
}

// 서버와의 통신을 담당
class Communicator {
  Communicator(this._onConnectServer, this._onTheaterStart,
      {this.serverIp = 'localhost', this.serverPort = 55555});

  final String serverIp;
  final int serverPort;
  Socket? _server;
  final void Function() _onConnectServer;
  final void Function() _onTheaterStart;

  final List<void Function(String)> listeners = [];
  void addMessageListener(void Function(String message) listener) {
    listeners.add(listener);
  }

  void removeMessageListener(void Function(String message) listener) {
    listeners.remove(listener);
  }

  void tryToConnectServer() {
    Socket.connect(serverIp, serverPort).then(
      (socket) {
        _server = socket;
        _server!
            .listen((data) => handleReceiveData(data))
            .onError((error) => handleReceiveError(error));

        // TODO : 개발 타임에 반드시 한번은 바인딩 될 수 있도록 할 것
        _onConnectServer();

        print('Connection from'
            '${_server!.remoteAddress.address}:${_server!.remotePort}');
      },
    ).onError(
      (error, stackTrace) {
        print('failed to connect to server :' '${error.toString()}');
      },
    );
  }

  // listen for events from the server and process
  void handleReceiveData(Uint8List data) async {
    final message = String.fromCharCodes(data);
    print('Server: $message');

    for (var listener in listeners) {
      listener(message);
    }

    if (message == 'theater_start') {
      // TODO : 개발 타임에 반드시 한번은 바인딩 될 수 있도록 할 것
      _onTheaterStart();
    }
  }

  void handleReceiveError(dynamic error) {
    print('Server data receive error : ' '{$error.toString()}');
  }

  // send message to connected server
  void sendMessage(String message) {
    _server!.write(message);
    print('Client: $message');
  }
}
