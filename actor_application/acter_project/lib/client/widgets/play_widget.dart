import 'package:acter_project/client/widgets/archive_page.dart';
import 'package:acter_project/client/widgets/select_page.dart';
import 'package:flutter/material.dart';

class PlayWidget extends StatefulWidget {
  const PlayWidget({super.key});

  @override
  State<PlayWidget> createState() => _PlayWidgetState();
}

class _PlayWidgetState extends State<PlayWidget> with TickerProviderStateMixin {
  late PageController _pageController;
  late TabController _tabController;
  late SelectPage _selectPage;
  late ArchivePage _archivePage;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tabController = TabController(length: 2, vsync: this);

    _selectPage = const SelectPage();
    _archivePage = const ArchivePage();
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
            children: <Widget>[_selectPage, _archivePage],

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
