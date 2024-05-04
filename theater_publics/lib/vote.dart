library;

import 'dart:typed_data';

import 'package:theater_publics/public.dart';

/// 클라이언트에게 투표를 진행하고, 찬성, 반대에 따라 등록된 업적을 전달합니다.
enum VoteType implements MessageTransableObject {
  skip,
  action;

  @override
  List<int> getMessage() => [index];
  @override
  bool equal(Uint8List msgData) => msgData[0] == (index);
}