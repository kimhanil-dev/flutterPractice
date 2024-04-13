import 'package:flutter/material.dart';

import 'package:acter_project/public.dart';

import 'widgets/main_app.dart';

void main() {
  runApp(const MainApp());
}

// 업적을 저장하고, 관리하는 클래스
class Archive {
  Archive();
  Archive.init();
  // read all achivements from server
  void init() {
    /* test code */
    achivements.add(
        Achivement(0, '첫번째 선택', Image.asset('images/0.jpg'), '당신의 첫번째 선택.'));

    achivements.add(Achivement(1, '첫번째 스킵', Image.asset('images/1.jpg'),
        '사람을 화나게하는 방법은 두가지가 있다고 합니다 그 첫번째는 말을 하다가 마는 것이고... '));

    achivements.add(
        Achivement(2, '나. 용사. 강림.', Image.asset('images/2.jpg'), '용사의 등장.'));

    achivements.add(Achivement(
        3, '의문의 음유시인', Image.asset('images/3.jpg'), 'Music is my life'));
  }

  List<Achivement> achivements = [];

  List<Achivement> getAllAchivements() {
    return achivements;
  }
}
