import 'package:flutter/material.dart';

import 'main_page.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.all(50.0),
          child: Text(
            '어느날 갑자기 용사가 되어 마왕을 무찌르게 된 \n한 소년의 이야기',
            textAlign: TextAlign.center,
          ),
        ),
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(_createRoute());
            },
            child: const Text('Press any key to start !')),
      ],
    );
  }
}

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const MainPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child;
    },
  );
}
