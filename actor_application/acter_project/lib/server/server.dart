import 'dart:io';
import 'dart:typed_data';

import 'package:acter_project/public.dart';

class Server {
  ServerSocket? server;
  List<Socket> clients = [];
  int skipCount = 0;
  int actionCount = 0;

  void init() async {
    server = await ServerSocket.bind(InternetAddress.anyIPv4, 55555);
    server!.listen((client) {
      handleConnection(client);
    });
  }

  void broadcastMessage(String message) {
    final messageData = MessageData(Header.basic, message, 0);
    final messageObject = MessageFactory.makeMessageClass(messageData);

    for (var client in clients) {
      client.write(messageObject.getMessage());
    }
  }

  // 클라이언트 연결 관리 및 로직 처리( 액션, 스킵 )
  void handleConnection(Socket client) {
    print('Connection from'
        ' ${client.remoteAddress.address}:${client.remotePort}');

    clients.add(client);

    // listen for events from the client
    client.listen(
      // handle data from the client
      (data) {
        handleClientData(client, data);
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

  void handleClientData(Socket client, Uint8List data) async {
    await Future.delayed(const Duration(seconds: 1));
    final message = Message.fromCharCodes(data);

    final messageClass = MessageFactory.makeMessageClassFromMessage(message);
    switch (messageClass.getHeader()) {
      case Header.withCallback:
        MessageData data = MessageData(Header.withCallback, 'complite', messageClass.getDatas().callbackId);
        client.write(MessageFactory.makeMessageClass(data).getMessage());
        break;
      default:
    }
  }

  // send achivement id to client
  void sendAchivement(Socket client, int id) {
    client.write(id.toString());
  }
}
