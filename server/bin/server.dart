import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:theater_publics/public.dart';

class Ping {
  Ping(this.dest, this.millisec);
  Socket dest;
  int millisec = 0;
}

class Server {
  ServerSocket? server;
  List<Socket> allSockets = [];
  List<Socket> clients = [];
  int skipCount = 0;
  int actionCount = 0;

  List<MessageListener> messageListeners = [];
  List<MessageWriter> messageWriter = [];

  Socket? screen;

  void init() async {
    server = await ServerSocket.bind(InternetAddress.anyIPv4, 55555);
    server!.listen((client) {
      handleConnection(client);
    });
  }

  void close() {
    if (_pingStreamController != null) {
      _pingStreamController!.close();
    }
    if (_pingtimer != null) {
      _pingtimer!.cancel();
    }
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

    // 클라이언트 연결시 초기 처리들 ..
    allSockets.add(client);

    sendMessage(dest: client, msgType: MessageType.onConnected);
    sendMessage(dest: client, msgType: MessageType.reqeustWhoAryYou);

    // listen for events from the client
    client.listen(
      // handle data from the client
      (data) {
        handleClientData(client, data);
      },

      // handle errors
      onError: (error) {
        print(error);
        allSockets.removeWhere(
            (element) => element.address.address == client.address.address);
        clients.removeWhere(
            (element) => element.address.address == client.address.address);
        client.close();
      },

      // handle the client closing the connection
      onDone: () {
        print('Client left');
        for (var e in messageListeners) {
          e.onDone(client);
        }

        clients.removeWhere(
            (element) => element.address.address == client.address.address);
        client.close();
      },
    );
  }

  void handleClientData(Socket client, Uint8List data) async {
    print('listen : ${client.address}, ');
    var messages = MessageHandler.getMessages(data);
    for (var message in messages) {
      // 연결이 client, controller, screen인지 파악
      if (message.messageType == MessageType.reqeustWhoAryYou) {
        if (message.datas[0] == Who.client.index) {
          clients.add(client);
          for (var element in messageWriter) {
            element.onSocketConnected(client);
          }
        }
      }

      // 연결 상태를 업데이트
      if (message.messageType == MessageType.ping) {
        if (_pingStreamController != null) {
          var deltaTime =
              DateTime.timestamp().difference(_pingStartTime).inMilliseconds;
          _pingStreamController!.sink.add(Ping(client, deltaTime));
        }
        continue;
      }

      print('received : ${message.messageType} : ${message.datas}');

      for (var listener in messageListeners) {
        listener.listen(client, message);
      }
    }
  }

  // send achivement id to client
  void sendAchivement(Socket client, int id) {
    client.write(id.toString());
  }

  DateTime _pingStartTime = DateTime.now();
  StreamController<Ping>? _pingStreamController;
  Timer? _pingtimer;
  Stream<Ping> createPingStream(Duration pingDuration) {
    _pingStreamController ??= StreamController<Ping>();

    _pingtimer ??= Timer.periodic(pingDuration, (timer) {
      _pingStartTime = DateTime.timestamp();
      broadcastMessage(messageType: MessageType.ping);
    });

    return _pingStreamController!.stream;
  }
}
