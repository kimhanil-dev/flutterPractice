import 'dart:io';
import 'dart:typed_data';

import 'package:acter_project/public.dart';

class Player {
  Player(this.connection, this.id,
      {this.ping = 0, this.isActionVoted = false, this.isSkipVoted = false});

  final int id;
  final Socket connection;
  int ping = 0;
  bool isSkipVoted = false;
  bool isActionVoted = false;
}

class BachedPlayerTrans implements MessageTransableObject{
  BachedPlayerTrans(this.byteData);
  final List<int> byteData;

  @override
  bool equal(Uint8List data) {
    return false;
  }

  @override
  List<int> getMessage() {
    return byteData;
  }

}

class Player_trans implements MessageTransableObject {

  static BachedPlayerTrans batchPlayers(List<Player> players) {
    List<int> result = [];
    for (var e in players) {
      result.addAll(Player_trans(e).getMessage());
    }
  
    return BachedPlayerTrans(result);
  }

  static List<Player_trans> unbatchPlayers(Uint8List datas) {
    List<Player_trans> result = [];
    for(int i = 0; (datas.length - i) >= 5; i+=5) {
      result.add(Player_trans.fromBytes(datas.sublist(i,i + 5)));
    }
    return result;
  }

  Player_trans(Player player) {
    _id = player.id < 0
        ? 0
        : player.id > 0xFF
            ? 0xFF
            : player.id & 0xFF;
    _ping = player.ping < 0
        ? 0
        : player.ping > 0xFFFF
            ? 0xFFFF
            : player.ping & 0xFFFF;
    _isSkipVoted = player.isSkipVoted;
    _isActionVoted = player.isActionVoted;
  }

  Player_trans.fromBytes(Uint8List bytes) {
    ByteData byteData = bytes.buffer.asByteData();
    if (byteData.lengthInBytes != 5) {
      throw Exception('Player_trans.fromBytes : invalid data');
    }

    int byteOffset = 0;
    _id = byteData.getInt8(byteOffset).toUnsigned(8);
    byteOffset += 1;
    _ping = byteData.getInt16(byteOffset).toUnsigned(16);
    byteOffset += 2;
    _isSkipVoted = byteData.getInt8(byteOffset) == 1 ? true : false;
    byteOffset += 1;
    _isActionVoted = byteData.getInt8(byteOffset) == 1 ? true : false;
  }

  int _id = 0;
  int _ping = 0;
  bool _isSkipVoted = false;
  bool _isActionVoted = false;

  int get id => _id;
  int get ping => _ping;
  bool get isSkipVoted => _isSkipVoted;
  bool get isActionVoted => _isActionVoted;

  @override
  bool equal(Uint8List data) {
    return _id == data[0];
  }

  @override
  List<int> getMessage() {
    return getBytes();
  }

  Uint8List getBytes() 
  {
    Uint8List bytes = Uint8List(5);
    bytes[0] = (_id & 0xFF);

    // ex) 5 : 0000 0000 0000 0101
    // _ping & 0xFF : 0000 0101
    // _(ping >> 8) & 0xFF : 0000 0000
    // 0000 0101 0000 0000 : 1280 < 틀린 값
    // _(ping >> 8) & 0xFF : 0000 0000
    // _ping & 0xFF : 0000 0101
    // 0000 0000 0000 0101 : 5 < 올바른 값

    // byte 배열을 합쳐서 읽을때 dart는 값의 오른쪽에 붙여 나간다
    // 읽는 방식은 선택가능 big endian, little endian
    bytes[1]=((_ping >>8)& 0xFF);
    bytes[2]=(_ping & 0xFF);
    bytes[3]=(isSkipVoted ? 0x1 : 0x0);
    bytes[4]=(isActionVoted ? 0x1 : 0x0);

    return bytes;
  }

  @override
  int get hashCode => super.hashCode;

  @override
  bool operator ==(Object other) {
    var o = other as Player_trans;
    return (_id == o.id) &&
        (_ping == o.ping) &&
        (isSkipVoted == o.isSkipVoted) &&
        (isActionVoted == o.isActionVoted);
  }

  @override
  String toString() {
    return '${_id} : ${_ping} : ${isSkipVoted} : ${isActionVoted}';
  }
}
