import 'package:acter_project/server/achivement.dart';
import 'package:flutter/material.dart';

import 'package:acter_project/public.dart';
import 'package:provider/provider.dart';

import 'archive.dart';
import 'widgets/main_app.dart';

void main() {
  runApp(Provider<Archive>(
    create: (_) => Archive(),
    child: const MainApp(),
  ));
}
