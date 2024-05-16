import 'package:acter_project/client/Services/client.dart';
import 'package:acter_project/client/widgets/page/vote_page.dart';
import 'package:acter_project/client/widgets/widget/corner.dart';
import 'package:acter_project/client/widgets/widget/message_button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Corner(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                    text: '연결',
                    color: Theme.of(context).primaryColor,
                    isActivated: true,
                    onPressed: () {
                      if (client.isConnected) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const VotePage()));
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const WaitConnectingPage()));
                      }
                    }),
                const Gap(50),
                CustomButton(
                    text: '기록',
                    color: Theme.of(context).primaryColor,
                    isActivated: true,
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const ArchivePage()));
                    })
              ],
            )
          ],
        ),
      ),
    );
  }
}
