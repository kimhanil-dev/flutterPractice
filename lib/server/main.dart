import 'package:acter_project/controller/commnuicator.dart';
import 'package:acter_project/server/achivement.dart';
import 'package:acter_project/server/play_manager.dart';

import 'package:acter_project/server/server.dart';

void main() async {
  final Server server = Server();
  final AchivementDB achivementDB = AchivementDB();
  late PlayManager chapterManager;
  late Communicator_server commnuicator;

  chapterManager = PlayManager();

  server.init();
  server.addMessageListener(chapterManager);
  server.addMessageWriter(chapterManager);

  await achivementDB.loadData();

  commnuicator = Communicator_server(server, chapterManager, achivementDB);
  server.addMessageListener(commnuicator);
  server.createPingStream(const Duration(seconds: 2)).listen((ping) {
    chapterManager.pingListener(ping);
    print('${ping.dest.address} : ${ping.millisec}');
  });
}
