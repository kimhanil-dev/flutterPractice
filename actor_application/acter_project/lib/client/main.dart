import 'package:acter_project/client/Services/archive.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'widgets/main_app.dart';

void main() {
  runApp(Provider<Archive>(
    create: (_) => Archive(),
    child: const MainApp(),
  ));
}
