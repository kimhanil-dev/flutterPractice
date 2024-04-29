import 'package:acter_project/client/Services/client.dart';
import 'package:acter_project/client/widgets/select_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'archive_page.dart';
import 'wait_connecting_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    var client = Provider.of<Client>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  if (client.isConnected) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const SelectPage()));
                  } else {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const WaitConnectingPage()));
                  }
                },
                child: const Text('선택')),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ArchivePage()));
                },
                child: const Text('기록')),
          ],
        ),
      ),
    );
  }
}
