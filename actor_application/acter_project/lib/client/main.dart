import 'package:acter_project/client/Services/archive.dart';
import 'package:acter_project/client/Services/client.dart';
import 'package:acter_project/client/Services/achivement_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:provider/provider.dart';

import 'widgets/main_app.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      Provider<Client>(create: (_) => Client()),
      Provider<AchivementDataManger>(create: (_) => AchivementDataManger(),),
      Provider<Archive>(create: (_) => Archive()),
    ],
    child: MainApp(key: UniqueKey(),),
  ));
}
  