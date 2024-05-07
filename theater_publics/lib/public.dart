library;
// 서버와 클라이언트를 위한 공용 코드 집합

import 'dart:io';
import 'dart:typed_data';

enum Who implements MessageTransableObject{
  client,
  controller,
  screen
  ;

  @override
  bool equal(Uint8List data) {
    return data[0] == index;
  }

  @override
  List<int> getMessage() {
    return [index];
  }
}

enum MessageType {
  onConnected,
  onTheaterStarted,
  onButtonClicked,
  onVoteComplited,
  onAchivement,
  onChapterChanged,
  onChapterEnd,
  activateSkipButton,
  activateActionButton,
  disableSkipButton,
  disableActionButton,
  onVote,
  ping,

  reqeustWhoAryYou,

  // controller to server
  onControllerConnected,
  requestStartThater,
  requestNextChapter,
  requestBroadcastSequenceAchivement,
  requestCurrentChapter,
  requestPlayerInfos,
  requestRestartTheater,

  // server to client
  answerControllerConnected,
  answerCurrentChapter,
  answerCurrentSequenceAchive,
  answerPlayerInfos,

  //screen
  screenMessage,
  nextSFX,
  ;

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
  ///  데이터를 넘겨줄때 STX와 ETX를 회피하기 위한 편향 값
  static const int _messageDataBias = 4;

  static void sendMessage(Socket dest, MessageType messageType,
      {MessageTransableObject? object}) {
    // STX and MessageType
    List<int> message = [1, messageType.index];

    // Data
    if (object != null) {
      var data = object.getMessage();
      for (int i = 0; i < data.length; ++i) {
        data[i] += _messageDataBias;
      }

      message += data;
    }

    // ETX
    message.add(3);

    dest.write(String.fromCharCodes(message));

    print('send : ${dest.address} : ${messageType.name}');
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
        messageType = MessageType.values[datas[++i]];
        dataStartIndex = i + 1;
      } else if (isInPacket && datas[i] == 3 /*ETX*/) {
        var msgDatas = datas.sublist(dataStartIndex, i);
        for (int i = 0; i < msgDatas.length; ++i) {
          msgDatas[i] -= _messageDataBias;
        }
        messageDatas.add(MessageData(messageType!, msgDatas));
        isInPacket = false;
      }
    }

    return messageDatas;
  }
}

abstract interface class MessageListener {
  void listen(Socket socket, MessageData msgData);
  void onDone(Socket socket);
}

abstract interface class MessageTransableObject {
  List<int> getMessage();
  bool equal(Uint8List data);
}

class BytesData implements MessageTransableObject {
  BytesData(this.bytes);
  List<int> bytes;

  @override
  bool equal(Uint8List data) {
    return bytes == data;
  }

  @override
  List<int> getMessage() {
    return bytes;
  }

}

class InstantMessageObject<T> implements MessageTransableObject{
  InstantMessageObject(this.data, this.toListFunc);
  final T data;
  final List<int> Function() toListFunc;

  @override
  bool equal(Uint8List data) {
    return this.data == data;
  }

  @override
  List<int> getMessage() {
    return toListFunc();
  }
}

abstract interface class MessageWriter {
  void onRegistered(List<Socket> sockets);
  void onSocketConnected(Socket newSocket);
}
