// public classes for server and client

// 업적 구조
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

// format functions
// 형식은 서버와 클라이언트 두 공간에서 사용하기 때문에, 해당 포멧을 함수화 하여,
// 변경이 발생할때 생길 수 있는 human error를 방지함.
//
// `포맷 규칙`
// 'Header,...'의 형태로 작성한다.
// `,`문자를 통해 데이터를 구분하며, Header는 해당 메시지가 어떤 형태의 메시지인지를 의미한다
//

/// Message 키워드는 포맷 함수를 거쳐 생성된 String을 의미합니다.
typedef Message = String;

/// 메시지 타입을 구분하기 위한 Header 열거형
enum Header {
  /// Header,message
  basic,

  /// Header,callbackId,message
  withCallback;

  /// message에서 Header를 추출합니다
  static Header extractHeader(Message message) {
    return Header.values[int.parse(message.split(message)[0])];
  }

  /// split된 message에서 Header 추출합니다.
  static Header getHeader(List<String> messages) {
    return Header.values[int.parse(messages[0])];
  }
}

class MessageData {
  MessageData(this.header, this.message,{this.callbackId});
  final Header header;
  final String message;
  int? callbackId;
  // add data..
}

// 반드시 응답이 이루어져야 하는 메시지에 대한 형식
// 전송, 응답 모두 같은 형태
class MessageFactory {
  static MessageBasic makeMessageClass(final MessageData messageData) {
    switch(messageData.header) {
      case Header.basic:
        return MessageBasic(messageData.message);
      case Header.withCallback:
        return MessageWithCallback(messageData.message,messageData.callbackId!);
      default:
        throw Exception('undefined Header : {message : ${messageData.header}}');
    }
  }
}

// 기본 메시지
class MessageBasic {
  MessageBasic(this.message);
  MessageBasic.fromMessage(final Message message) {
    _fromMessage(message);
  }

  late String message;

  /// `class`의 데이터를 초기화하는 함수
  @mustBeOverridden
  List<String> _fromMessage(final Message message) {
    var strs = _splitMessage(message);
    if (int.parse(strs[0]) == getHeader()) {
      this.message = strs[1];
    } else {
      throw Exception('not matched `Header` : ${strs[0]}');
    }

    return strs;
  }

  /// 메시지의 `Header`를 정의합니다.
  @mustBeOverridden
  Header getHeader() {
    return Header.basic;
  }

  /// 서버에 전송될 수 있는 형태의 메시지 생성
  /// 
  /// 재정의 시 super.getMessage()의 반환값의 뒤쪽에 `,`문자를 구분자로 하여 데이터를 추가합니다.
  @mustBeOverridden
  Message getMessage() {
    return  '${Header.withCallback.index},$message';
  }

  /// Message를 구분 패턴을 통해 List<String>로 분리합니다.
  ///
  /// List<String>에 대한 데이터의 의미는, Header타입을 참고합니다.
  List<String> _splitMessage(Message message) {
    return message.split(',');
  }
}

// 응답이 필요한 메시지
class MessageWithCallback extends MessageBasic {
  MessageWithCallback(super.message, this.callbackId);
  MessageWithCallback.fromMessage(super.message);

  @override
  Header getHeader() {
    return Header.withCallback;
  }

  late int callbackId;

  @override
  List<String> _fromMessage(Message message) {
    var strs = super._fromMessage(message);
    callbackId = int.parse(strs[2]);

    return strs;
  }
  
  @override
  Message getMessage() {
    return '${super.message},$callbackId';
  }
}

class Achivement {
  const Achivement(this.id, this.name, this.image, this.text);
  final int id;
  final String name;
  final Image image;
  final String text; // 업적 설명문
}
