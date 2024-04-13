import 'dart:io';
import 'dart:typed_data';

import 'package:acter_project/public.dart';

/// connectToServer로 서버에 연결합니다.
/// addMessageListener()에 함수를 추가하여 서버로 부터 데이터를 받습니다.
/// sendMessage...()함수를 통해 서버에 메시지를 전달합니다.
class Client {
  late Socket _server;

  List<Function(String message)> messageListeners = [];

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

  void addMessageListener(void Function(String) messageListener) {
    messageListeners.add(messageListener);
  }

  void sendMessage(MessageType message) {
    message.sendTo(_server);
  }

  /// Server에서 데이터가 전달될 경우 실행되는 함수
  void listen(Uint8List data) {
    final String message = String.fromCharCodes(data);
    for (var element in messageListeners) {
      element(message);
    }
  }
}
