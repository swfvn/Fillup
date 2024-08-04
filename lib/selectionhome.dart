import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:fiil_up_app/home.dart';
import 'package:fiil_up_app/profile/profile.dart';
import 'package:flutter/material.dart';

class HomeSelection extends StatefulWidget {
  const HomeSelection({Key? key}) : super(key: key);

  @override
  State<HomeSelection> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomeSelection>
    with SingleTickerProviderStateMixin {
  int _tabIndex = 0;
  int get tabIndex => _tabIndex;
  set tabIndex(int v) {
    _tabIndex = v;
    setState(() {});
  }

  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: _tabIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: CircleNavBar(
        activeIcons: const [
          Icon(Icons.local_shipping, color: Colors.black),
          Icon(Icons.person, color: Colors.black),
        ],
        inactiveIcons: const [
          Text(
            "Home",
            style: TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            "Profile",
            style: TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
        color: Colors.yellow,
        height: 80,
        circleWidth: 70,
        activeIndex: tabIndex,
        onTap: (index) {
          tabIndex = index;
          pageController.jumpToPage(tabIndex);
        },
        padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
        cornerRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (v) {
          tabIndex = v;
        },
        children: [
          HomeScreen(),
          Profile(),
        ],
      ),
    );
  }
}
