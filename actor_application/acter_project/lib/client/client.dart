import 'dart:io';
import 'dart:typed_data';

import 'package:acter_project/public.dart';

/// connectToServer로 서버에 연결합니다.
/// addMessageListener()에 함수를 추가하여 서버로 부터 데이터를 받습니다.
/// sendMessage...()함수를 통해 서버에 메시지를 전달합니다.
class Client {
  late Socket _server;

  // TODO: 연결 실패시의 처리 추가
  /// 연결 성공시 서버로 부터 Header.basic 형태의 MessagePreset.connected가 전달 됩니다.
  void connectToServer(final String serverIp, final int serverPort,
      void Function(bool) onConnectionResult) {
    Socket.connect(serverIp, serverPort).then((server) {
      _server = server;
      _server.listen(listen);
      onConnectionResult(true);

      print('Connection from'
          '${_server.remoteAddress.address}:${_server.remotePort}');
    });
  }

  int _callbackIndex = 0;
  // TODO:callback리스트를 청소하는 코드 작성할 것
  final List<void Function(String)> _messageCallbacks = [];
  final List<void Function(String)> _messageListener = [];

  void addMessageListener(void Function(String) messageListener) {
    _messageListener.add(messageListener);
  }

  void sendMessage(String message) {
    final messageData = MessageData(Header.basic, message, -1);
    _server.write(MessageFactory.makeMessageClass(messageData).getMessage());
  }

  /// 응답에 대한 처리가 존재하는 메시지를 생성하여 서버에 전달합니다.
  void sendMessageWithCallback(String message, void Function(String) callback) {
    final messageData =
        MessageData(Header.withCallback, message, _callbackIndex++);
    _server.write(MessageFactory.makeMessageClass(messageData).getMessage());
    _messageCallbacks.add(callback);
  }

  /// Server에서 데이터가 전달될 경우 실행되는 함수
  void listen(Uint8List data) {
    final Message message = Message.fromCharCodes(data);
    var messages = message.split('!');
    for (var msg in messages) {
      var messageClass = MessageFactory.makeMessageClassFromMessage(msg);
      switch (messageClass.getHeader()) {
        case Header.withCallback: // run callback
          var datas = messageClass.getDatas();
          _messageCallbacks[datas.callbackId](datas.message);
          break;
        case Header.basic: // boradcast to listeners
          for (var listener in _messageListener) {
            listener(messageClass.message);
          }
          break;
        default:
          throw Exception(
              'server message not handled [Header : ${messageClass.getHeader()}]');
      }
    }
  }
}
