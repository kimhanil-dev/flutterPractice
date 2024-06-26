import 'package:acter_project/client/widgets/page/archive_page.dart';
import 'package:acter_project/client/widgets/page/vote_page.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

class PlayPage extends StatefulWidget {
  const PlayPage({super.key});

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> with TickerProviderStateMixin {
  late PageController _pageController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tabController = TabController(length: 2, vsync: this);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          PageView(
            controller: _pageController,
            onPageChanged: _handlePageViewChanged,
            children: const <Widget>[LoaderOverlay(child: VotePage()), ArchivePage()],

          ),
          TabBar(
            tabs: const [
              Tab(icon: Icon(Icons.archive)),
              Tab(icon: Icon(Icons.explore)),
            ],
            controller: _tabController,
            onTap: _handleTap,
          ),
        ],
      ),
    );
  }

  void _handleTap(int index) {
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 400), curve: Curves.easeInSine);
  }

  void _handlePageViewChanged(int currentPageIndex) {}
}
