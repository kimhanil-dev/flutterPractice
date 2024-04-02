import 'dart:io';
import 'dart:typed_data';

import 'package:acter_project/public.dart';

class Client {
  int _callbackIndex = 0;
  // TODO:callback리스트를 청소하는 코드 작성할 것
  final List<void Function(String)> _messageCallbacks = [];
  final List<void Function(String)> _messageListener = [];

  void addMessageListener(void Function(String) messageListener) {
    _messageListener.add(messageListener);
  }

  /// 응답에 대한 처리가 존재하는 메시지를 생성하여 서버에 전달합니다.
  void sendMessageWithCallback(
      Socket server, String message, void Function(String) callback) {
    server.write(MessageWithCallback(message, _callbackIndex++).getMessage());
    _messageCallbacks.add(callback);
  }

  /// Server에서 데이터가 전달될 경우 실행되는 함수
  void listen(Uint8List data) {
    final Message message = Message.fromCharCodes(data);
    var messageClass = MessageFactory.makeMessageClassFromMessage(message);
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
