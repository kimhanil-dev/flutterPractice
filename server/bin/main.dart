import 'package:dotenv/dotenv.dart';
import 'package:theater_publics/achivement.dart';

import 'communicator.dart';
import 'play_manager.dart';
import 'server.dart';

void main(List<String> args) async {
  final Server server = Server();
  final AchivementDB achivementDB = AchivementDB();
  late PlayManager chapterManager;
  late Communicator_server commnuicator;

  chapterManager = PlayManager();

  server.init();
  server.addMessageListener(chapterManager);
  server.addMessageWriter(chapterManager);

  var dotEnv = DotEnv();
  dotEnv.load();

  await achivementDB.loadData(dotEnv['GSHEETS_CREDENTIALS']!);

  commnuicator = Communicator_server(server, chapterManager, achivementDB);
  server.addMessageListener(commnuicator);
  chapterManager.addPlayInfoListener(commnuicator);

  server.createPingStream(const Duration(seconds: 2)).listen((ping) {
    chapterManager.pingListener(ping);
    print('${ping.dest.address} : ${ping.millisec}');
  });

  print('server started');
}
