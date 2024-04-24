import 'dart:io';
import 'dart:typed_data';

import 'package:acter_project/public.dart';

class Server {
  ServerSocket? server;
  List<Socket> clients = [];
  int skipCount = 0;
  int actionCount = 0;

  List<MessageListener> messageListeners = [];
  List<MessageWriter> messageWriter = [];

  void init() async {
    server = await ServerSocket.bind(InternetAddress.anyIPv4, 55555);
    server!.listen((client) {
      handleConnection(client);
    });
  }

  void addMessageListener(MessageListener msgListener) {
    messageListeners.add(msgListener);
  }

  void addMessageWriter(MessageWriter msgWriter) {
    msgWriter.onRegistered(clients);
    messageWriter.add(msgWriter);
  }

  void sendMessage(
      {required Socket dest,
      required MessageType msgType,
      MessageTransableObject? object}) {
    MessageHandler.sendMessage(dest, msgType, object: object);
  }

  void broadcastMessage(
      {required MessageType messageType, MessageTransableObject? object}) {
    multicastMessage(dests: clients, msgType: messageType, object: object);
  }

  void multicastMessage(
      {required List<Socket> dests,
      required MessageType msgType,
      MessageTransableObject? object}) {
    for (var dest in dests) {
      sendMessage(dest: dest, msgType: msgType, object: object);
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

    for (var element in messageWriter) {
      element.onSocketConnected(client);
    }

    // listen for events from the client
    client.listen(
      // handle data from the client
      (data) {
        handleClientData(client, data);
      },

      // handle errors
      onError: (error) {
        print(error);
        clients.removeWhere((element) => element.address == client.address);
        client.close();
      },

      // handle the client closing the connection
      onDone: () {
        print('Client left');
        clients.removeWhere((element) => element.address == client.address);
        client.close();
      },
    );
  }

  void handleClientData(Socket client, Uint8List data) async {
    await Future.delayed(const Duration(seconds: 1));

    print('listen : ${client.address}, ');
    var messages = MessageHandler.getMessages(data);
    for (var message in messages) {
    print('type : ${message.messageType} , datas : ${message.datas}');
      for (var listener in messageListeners) {
        listener.listen(client, message);
      }
    }

  }

  // send achivement id to client
  void sendAchivement(Socket client, int id) {
    client.write(id.toString());
  }
}
