import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() async {
  // for broadcast
  List<Socket> clients = [];
  // bind the socket server to an address and port
  var server = await ServerSocket.bind(InternetAddress.anyIPv4, 55555);
  server.listen(
    (client) {
      handleConnection();
    },
  );

  runApp(MainApp(server, clients));
}

class Server {
  ServerSocket? socket;
  List<Socket> clients = [];
  int skipCount = 0;
  int actionCount = 0;

  void init() async {
    socket = await ServerSocket.bind(InternetAddress.anyIPv4, 55555);
  }

  // 클라이언트 연결 관리 및 로직 처리( 액션, 스킵 )
  void handleConnection(Socket client, List<Socket> clients) {
    print('Connection from'
        ' ${client.remoteAddress.address}:${client.remotePort}');

    clients.add(client);

    // listen for events from the client
    client.listen(
      // handle data from the client
      (Uint8List data) async {
        await Future.delayed(const Duration(seconds: 1));
        final message = String.fromCharCodes(data);
        if (message == '스킵') {
          ++skipCount;
          if (skipCount >= (clients.length * 0.6)) {
            for (var client in clients) {
              client.write('스킵완료');
              skipCount = 0;
            }
          }
        } else if (message == '액션') {
          ++actionCount;
          for (var client in clients) {
            client.write('액션완료');
            actionCount = 0;
          }
        }
      },

      // handle errors
      onError: (error) {
        print(error);
        client.close();
        clients.remove(client);
      },

      // handle the client closing the connection
      onDone: () {
        print('Client left');
        client.close();
        clients.remove(client);
      },
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp(this.server, this.clients, {super.key});
  final ServerSocket server;
  final List<Socket> clients;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              ElevatedButton(
                  onPressed: () async {
                    for (var client in widget.clients) {
                      client.write('theater_start');
                    }
                  },
                  child: const Text('Start theater'))
            ],
          ),
        ),
      ),
    );
  }
}
