import 'package:acter_project/client/Services/archive.dart';
import 'package:acter_project/client/Services/achivement_manager.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';


class ArchivePage extends StatelessWidget {
  const ArchivePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.loaderOverlay.show();
    final achivementDataManager = Provider.of<AchivementDataManger>(context);
    final archive = Provider.of<Archive>(context);
    ArchiveSaveLoader.load(archive)
        .then((value) {
          context.loaderOverlay.hide();
        });

    return Scaffold(
      body: GridView(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        children: [
          for (var id in archive.achivements)
            Row(
              children: [
                Expanded(
                    child: AspectRatio(
                        aspectRatio: 1,
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: achivementDataManager.getImage(id),
                        ))),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AutoSizeText(
                      id.toString(),
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    AutoSizeText(
                      achivementDataManager.getData(id).name,
                      style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ))
              ],
            ),
        ],
      ),
    );
  }
}
