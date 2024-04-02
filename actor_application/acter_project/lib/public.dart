// 서버와 클라이언트를 위한 공용 코드 집합

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

// ------------------------------- Description -------------------------------

// Message Classes
//
// 메시지는 서버와 클라이언트 두 공간에서 사용하기 때문에, 메시지들을 객체화 하여
// 변경 사항이 발생하거나, 데이터를 읽고 쓰는 과정에서 발생하는 에러를 방지함

// function만 제공하는 것이 아니라 class 형태로 제공된 이유
// 
// 데이터와 함수를 가깝게 하여, 변경 사항이나 해당 데이터에 대한 탐색이 필요할 시 
// 이를 용이하게 하기 위함과, MessageFactory를 통해 코드를 일반화 시키기 위함이다.
// 일반화를 통해 얻고자 하는 이점은, 코드의 단순화 및 밀집도 상승이다.
// 

// 메시지 형태를 추가할 경우 변경해야 하는 것들
// 1. enum Header에 메시지 타입 추가
// 2. MessageData에 데이터 추가
// 3. MessageFactory에 생성 코드 추가
// 4. MessageBasic을 상속한 메시지 클래스 작성

// ------------------------------- Description end -------------------------------

// ------------------------------- 메시지 Header -------------------------------

/// 서버나 클라이언트에 전달될 수 있는 형태를 가지고 있음을 의미하며,
/// 일반 String과 구별하기 위해 정의됩니다.
typedef Message = String;

/// 메시지 타입을 구분하기 위한 Header 열거형
/// 
/// enum Header의 요소와 Message 객체는 1:1 관계이어야 합니다. 
/// ex) basic : MessageBasic
enum Header {
  /// Header,message
  basic,

  /// Header,callbackId,message
  withCallback;

  /// message에서 Header를 추출합니다
  static Header extractHeader(Message message) {
    return Header.values[int.parse(message.split(',')[0])];
  }

  /// split된 message에서 Header 추출합니다.
  static Header getHeader(List<String> messages) {
    return Header.values[int.parse(messages[0])];
  }
}
// ------------------------------- 메시지 Header end -------------------------------

// ------------------------------- 메시지 Factory -------------------------------

/// `MessageFactory`에 전달될 데이터 집합입니다.
class MessageData {
  MessageData(this.header, this.message,this.callbackId);
  final Header header;
  final String message;
  int callbackId;
  // add data..
}

// 반드시 응답이 이루어져야 하는 메시지에 대한 형식
// 전송, 응답 모두 같은 형태

/// `MessageData`의 `Header`값에 따라 Message 인스턴스를 생성합니다.
class MessageFactory {
  static MessageBasic makeMessageClass(final MessageData messageData) {
    switch(messageData.header) {
      case Header.basic:
        return MessageBasic(messageData.message);
      case Header.withCallback:
        return MessageWithCallback(messageData.message,messageData.callbackId);
      default:
        throw Exception('undefined Header : { header : ${messageData.header} }');
    }
  }

  static MessageBasic makeMessageClassFromMessage(final Message message) {
    switch(Header.extractHeader(message)) {
      case Header.basic:
        return MessageBasic.fromMessage(message);
      case Header.withCallback:
        return MessageWithCallback.fromMessage(message);
      default:
        throw Exception('undefined Header : { message : $message }');
    }
  }
}

// ------------------------------- 메시지 Factory end -------------------------------


// ------------------------------- 메시지 클래스 -------------------------------
/*
  메시지 추가시 MessageBasic이나 하위 클래스를 상속받아 작성합니다.

  하위 클래스 작성시 유의해야할 사항
  1. getHeader()를 재정의 하여 어떤 메시지인지 정의 하여야 합니다.
  2. _fromMessage()를 서버 메시지를 해석하는 함수로, fromMessage() 생성자를 통해 MessageFactroy에서 호출됩니다.
  3. getMessage()를 통해 데이터를 전송 가능한 형태로 변환하여 반환합니다.
    3-1 변환 규칙
      - `Message`데이터 형으로 전달한다
      - `,`문자를 구분자로 사용한다.
      - 첫 번째 데이터에는 반드시 enum Header의 index를 위치한다.
      4. getDatas()를 재정의 하여 데이터를 반환한다.
*/

/// 기본 메시지 형태
/// 
/// message 데이터를 소유
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
    if (int.parse(strs[0]) == getHeader().index) {
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
    return  '${getHeader().index},$message';
  }

  @mustBeOverridden
  MessageData getDatas() {
    return MessageData(getHeader(),message,-1);
  }

  /// Message를 구분 패턴을 통해 List<String>로 분리합니다.
  ///
  /// List<String>에 대한 데이터의 의미는, Header타입을 참고합니다.
  List<String> _splitMessage(Message message) {
    return message.split(',');
  }
}

/// 응답이 필요한 메시지 형태
/// 
/// 호출되어야 할 Callback에 대한 id를 소유
class MessageWithCallback extends MessageBasic {
  MessageWithCallback(super.message, this.callbackId);
  MessageWithCallback.fromMessage(final Message message)
    :super.fromMessage(message);

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
    return '${super.getMessage()},$callbackId';
  }
  
  @override
  MessageData getDatas() {
    return MessageData(getHeader(),message, callbackId);
  }
}

// ------------------------------- 메시지 클래스 end -------------------------------


class Achivement {
  const Achivement(this.id, this.name, this.image, this.text);
  final int id;
  final String name;
  final Image image;
  final String text; // 업적 설명문
}
