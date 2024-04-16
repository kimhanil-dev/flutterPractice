import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:acter_project/public.dart';

class Server {
  ServerSocket? server;
  List<Socket> clients = [];
  int skipCount = 0;
  int actionCount = 0;

  List<MessageListener> messageListeners = [];

  void init() async {
    server = await ServerSocket.bind(InternetAddress.anyIPv4, 55555);
    server!.listen((client) {
      handleConnection(client);
    });
  }

  void addMessageListener(MessageListener msgListener) {
    messageListeners.add(msgListener);
  }

  void broadcastMessage({required MessageType messageType, List<int>? datas}) {
    for (var client in clients) {
      MessageHandler.sendMessage(client, messageType,datas: datas);
    }
  }

  void sendMessage({required Socket dest,required MessageType msgType, List<int>? datas}) {
    MessageHandler.sendMessage(dest, msgType, datas: datas);
  }

  void multicastMessage({required List<Socket> dests,required MessageType msgType, List<int>? datas}) {
    for (var dest in dests) {
      MessageHandler.sendMessage(dest, msgType,datas: datas);
    }
  }

  // 클라이언트 연결 관리 및 로직 처리( 액션, 스킵 )
  void handleConnection(Socket client) {
    print('Connection from'
        ' ${client.remoteAddress.address}:${client.remotePort}');

    clients.add(client);

    // 클라이언트 연결시 초기 처리들 ..
    MessageHandler.sendMessage(client, MessageType.onConnected);
    //

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

    var messages = MessageHandler.getMessages(data);
    for (var message in messages) {
      for (var listener in messageListeners) {
        listener.listen(client, message);
      }

      switch (message.messageType) {
        case MessageType.onButtonClicked:
          {
            MessageHandler.sendMessage(client, MessageType.onComplited);
            MessageType.onAchivement.sendTo(client);
          }
          break;
        default:
          throw Exception('$message is not declared message type');
      }
    }
  }

  // send achivement id to client
  void sendAchivement(Socket client, int id) {
    client.write(id.toString());
  }
}
