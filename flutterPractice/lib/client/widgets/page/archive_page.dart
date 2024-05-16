import 'package:acter_project/client/Services/archive.dart';
import 'package:acter_project/client/Services/achivement_manager.dart';
import 'package:acter_project/client/widgets/page/achivement_detail_page.dart';
import 'package:acter_project/client/widgets/widget/framed_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

import '../widget/corner.dart';

class ArchivePage extends StatelessWidget {
  const ArchivePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.loaderOverlay.show();
    final achivementDataManager = Provider.of<AchivementDataManger>(context);
    final archive = Provider.of<Archive>(context);
    ArchiveSaveLoader.load(archive).then((value) {
      context.loaderOverlay.hide();
    });

    return Scaffold(
      body: Stack(children: [
        const Corner(),
        Column(
          children: [
           
            Expanded(
                child: Column(
                  children: [
                    const Gap(30),
                     Text('업적',style: TextStyle(color: Theme.of(context).primaryColor,fontSize: 28),),
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: SvgPicture.asset(
                        'assets/images/ui/Callout5.svg',
                        colorFilter: ColorFilter.mode(
                            Theme.of(context).primaryColor, BlendMode.srcIn),
                      ),
                    ),
                  ],
                )),
            Expanded(
              flex: 3,
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4),
                children: [
                  for (var id in archive.achivements)
                    AspectRatio(
                        aspectRatio: 1,
                        child: IconButton(
                          icon: FittedBox(
                            fit: BoxFit.fill,
                            child: Hero(
                                tag: id.toString(),
                                child: FramedImage(
                                  width: 150,
                                  height: 150,
                                  image: achivementDataManager.getImage(id),
                                )),
                          ),
                          onPressed: () =>
                              Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                AchivementDetailPage(achiveId: id),
                          )),
                        )),
                ],
              ),
            ),
          ],
        ),
      ]),
    );
  }
}
