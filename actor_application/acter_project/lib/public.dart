// 서버와 클라이언트를 위한 공용 코드 집합

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

enum MessageType {
  onConnected,
  onTheaterStarted,
  onButtonClicked,
  onComplited,
  onAchivement,
  activateSkipButton,
  activateActionButton,
  disableSkipButton,
  disableActionButton;

  static MessageType getMessage(String message) =>
      MessageType.values[int.parse(message)];

  void sendTo(Socket destination) => destination.write(index);
}

/// 데이터 구조
/// [0] = [STX] 1
/// [1] = length
/// [2] = MessageType
/// [3] = data ....
/// [....n] = [ETX] 3
class MessageData {
  MessageData(this.messageType, this.datas);
  final MessageType messageType;
  final Uint8List datas;
}

class MessageHandler {
  static void sendMessage(Socket dest, MessageType messageType,
      {String? datas}) {
    // STX and MessageType
    String message = String.fromCharCode(1) + messageType.index.toString();

    // Data
    if (datas != null) {
      message += datas;
    }

    // ETX
    message += String.fromCharCode(3);

    dest.write(message);
  }

  static List<MessageData> getMessages(Uint8List datas) {
    List<MessageData> messageDatas = [];
    bool isInPacket = false;
    int dataStartIndex = 0;
    MessageType? messageType;
    for (int i = 0; i < datas.length; ++i) {
      if (datas[i] == 1 /*STX*/ && !isInPacket) {
        isInPacket = true;
                        // ascii number to int
        messageType = MessageType.values[datas[++i] - 48];
        dataStartIndex = ++i;

        if (datas[dataStartIndex] == 3 /*ETX*/) {
          isInPacket = false;
        }
        
      } else if (isInPacket && datas[i] == 3 /*ETX*/) { 
        messageDatas.add(MessageData(messageType!, datas.sublist(dataStartIndex, i - 1)));
        isInPacket = false;
      }
    }

    return messageDatas;
  }
}

class Achivement {
  const Achivement(this.id, this.name, this.image, this.text);
  final int id;
  final String name;
  final Image image;
  final String text; // 업적 설명문
}
