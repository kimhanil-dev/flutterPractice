library;
// 서버와 클라이언트를 위한 공용 코드 집합

import 'dart:io';
import 'dart:typed_data';

import 'package:theater_publics/vote.dart';

enum Who implements MessageTransableObject {
  client,
  controller,
  screen;

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
  onFailed,
  onConnected,
  onTheaterStarted,
  onButtonClicked,
  onVoteComplited(parser: StringData.parse,dataType: StringData),
  onAchivement(parser: Achivement.parse,dataType: Achivement),
  onChapterChanged,
  onChapterEnd,
  onUpdateButtonState,
  onLockUpdate(parser: BoolData.parse,dataType: BoolData),
  onVote(parser: VoteData.parser),
  setChapter(parser: IntData.parse,dataType: IntData),
  startInstanceActionVote(parser: IntData.parse,dataType: IntData),
  setBlack,
  sendName(parser: StringData.parse, dataType: StringData),
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

  //client to server
  requestCurrentVotes,
  ;

  const MessageType({this.parser, Type? dataType}) : _dataType = dataType;

  @override
  get runtimeType => _dataType.runtimeType;

  final Type? _dataType;
  final dynamic Function(MessageData)? parser;

  static MessageType getMessage(String message) =>
      MessageType.values[int.parse(message)];

  void sendTo(Socket destination) => destination.write(index);
}

class StringData extends MessageTransableObject{
  final String value;

  StringData(this.value);
  StringData.fromBytes(Uint8List bytes) : value = String.fromCharCodes(bytes);

  @override
  bool equal(Uint8List data) {
    return value == StringData.fromBytes(data).value;
  }

  @override
  List<int> getMessage() {
    return [...value.codeUnits];
  }

  static StringData parse(MessageData msgData) {
    return StringData.fromBytes(msgData.datas);
  }
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

    try {
    dest.write(String.fromCharCodes(message));
    } catch(e) {
      print(e);
    }

    print('send : ${dest.address} : ${messageType.name}');
  }

  static List<MessageData> getMessages(Uint8List datas) {
    try {
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
    } on Exception {
      return [];
    }
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

class VoteData implements MessageTransableObject {
  VoteData(this.type, this.max, this.current);
  VoteData.fromBytes(Uint8List data) {
    type = VoteType.values[data[0]];
    max = data[1];
    current = data[2];
  }
  late final VoteType type;
  late final int max;
  late final int current;

  @override
  bool equal(Uint8List data) {
    var voteData  = VoteData.fromBytes(data);
    return (type == voteData.type && max == voteData.max && current == voteData.current);
  }

  @override
  List<int> getMessage() {
    return [type.index, max, current];
  }

  static VoteData parser(MessageData msgData) {
    return VoteData.fromBytes(msgData.datas);
  }
}

class InstantMessageObject<T> implements MessageTransableObject {
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

class ButtonStates implements MessageTransableObject {
  ButtonStates(this.isSkipEnabled, this.isActionEnabled);
  ButtonStates.fromBytes(Uint8List bytes) {
    isSkipEnabled = _intToBoolean(bytes[0]);
    isActionEnabled = _intToBoolean(bytes[1]);
  }
  bool isSkipEnabled = false;
  bool isActionEnabled = false;

  bool _intToBoolean(int value) {
    return value == 1 ? true : false;
  }

  int _booleanToInt(final bool value) {
    return value ? 1 : 0;
  }

  @override
  bool equal(Uint8List data) {
    return (_booleanToInt(isSkipEnabled) == data[0]) && (_booleanToInt(isActionEnabled) == data[1]);
  }

  @override
  List<int> getMessage() {
    return [_booleanToInt(isSkipEnabled), _booleanToInt(isActionEnabled)];
  }

}

abstract interface class MessageWriter {
  void onRegistered(List<Socket> sockets);
  void onSocketConnected(Socket newSocket);
}

class Achivement implements MessageTransableObject {
  final int id;

  Achivement({required this.id});
  Achivement.fromBytes(Uint8List data) : id = int.parse(String.fromCharCodes(data));

  @override
  bool equal(Uint8List data) {
    return id == Achivement.fromBytes(data).id;
  }

  @override
  List<int> getMessage() {
    return id.toString().codeUnits;
  }


  static Achivement parse(MessageData msgData) {
    return Achivement.fromBytes(msgData.datas);
  }
}

class BoolData implements MessageTransableObject {
  final bool condition;

  BoolData({required this.condition});
  BoolData.fromBytes(Uint8List bytes) : condition = bytes[0] == 1 ? true : false;
  
  @override
  bool equal(Uint8List data) {
    return condition == BoolData.fromBytes(data).condition;
  }
  
  @override
  List<int> getMessage() {
    return [condition ? 1 : 0];
  }

  static BoolData parse(MessageData msgData) {
    return BoolData.fromBytes(msgData.datas);
  }  
}

class IntData implements MessageTransableObject {
  final int value;

  IntData(this.value);
  IntData.fromBytes(Uint8List bytes) : value = int.parse(String.fromCharCodes(bytes));
  
  @override
  bool equal(Uint8List data) {
    return value == IntData.fromBytes(data).value;
  }
  
  @override
  List<int> getMessage() {
    return [...value.toString().codeUnits];
  }

  static IntData parse(MessageData msgData) {
    return IntData.fromBytes(msgData.datas);
  }
}