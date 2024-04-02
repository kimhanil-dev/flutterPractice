import 'dart:io';
import 'dart:typed_data';

import 'package:acter_project/public.dart';


class client {

  int _callbackIndex = 0;
  final List<void Function(Uint8List)> _messageCallbacks = [];

  void sendMessageWithCallback(
      Socket server, String message, void Function(Uint8List) callback) {
    server.write(MessageWithCallback(message, _callbackIndex++));
    _messageCallbacks.add(callback);
  }

  void listen(Uint8List data) {
    final message = String.fromCharCodes(data);
    var messageClass = MessageFactory.makeMessageClass(message);
    switch(messageClass.getHeader()) {
      case Header.withCallback:
        
      break;
      default:
        throw Exception('server message not handled [Header : ${messageClass.getHeader()}]');
    }
  }

  void runCallback(final int index, final Uint8List data) {
    _messageCallbacks[_callbackIndex](data);
  }
}
