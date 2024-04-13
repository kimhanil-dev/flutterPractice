import 'dart:io';

import 'package:acter_project/public.dart';
import 'package:acter_project/server/achivement.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {



  MessageHandler.sendMessage()
  test('데이터 전송, 수신 테스트', () async {
      ServerSocket localServer = await ServerSocket.bind('localhost', 55555);
      Socket localClient = await Socket.connect('localhost', 55555);
      
  });
}
