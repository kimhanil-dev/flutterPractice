import 'dart:io';
import 'dart:typed_data';

import 'package:acter_project/public.dart';

/// connectToServer로 서버에 연결합니다.
/// addMessageListener()에 함수를 추가하여 서버로 부터 데이터를 받습니다.
/// sendMessage...()함수를 통해 서버에 메시지를 전달합니다.
class Client {
  Client({this.clientType = Who.client});

  final Who clientType;
  Socket? _server;
  bool _bIsConnected = false;

  List<Function(MessageData)> messageListeners = [];


  bool get isConnected => _bIsConnected;

  // TODO: 연결 실패시의 처리 추가
  /// 연결 성공시 서버로 부터 onConnect가 전달 됩니다.
  void connectToServer(final String serverIp, final int serverPort,
      void Function(bool) onConnectionResult) {
    if (_server == null) {
      Socket.connect(serverIp, serverPort,timeout: const Duration(days: 1)).then((server) {
        _server = server;
        _server!.listen(listen);
        onConnectionResult(true);

        _server!.done.then((value) {
          //TODO : 런타임 로그 남기기
          print('server connection closed : ${value.toString()}');
          _bIsConnected = false;
        });

        _bIsConnected = true;

        print('Connection from'
            '${_server!.remoteAddress.address}:${_server!.remotePort}');
      });
    }
  }

  void addMessageListener(void Function(MessageData) messageListener) {
    messageListeners.add(messageListener);
  }

  void sendMessage(
      {required MessageType message, MessageTransableObject? object}) {
    MessageHandler.sendMessage(_server!, message, object: object);
  }

  /// Server에서 데이터가 전달될 경우 실행되는 함수
  void listen(Uint8List data) {
    var messages = MessageHandler.getMessages(data);
    for (var element in messageListeners) {
      for (var msg in messages) {

        if(msg.messageType == MessageType.reqeustWhoAryYou) {
          sendMessage(message: MessageType.reqeustWhoAryYou, object: clientType);
          continue;
        }

        if(msg.messageType == MessageType.ping) {
          sendMessage(message: MessageType.ping);
          continue;
        }
        element(msg);
      }
    }
  }

  void close() {
    _server?.close();
  }
}
