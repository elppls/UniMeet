import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:unimeet_test/Screens/ClubsScreen.dart';
import 'package:unimeet_test/Screens/CreatePostScreen.dart';
import 'package:unimeet_test/Screens/HomeScreen.dart';
import 'package:unimeet_test/Screens/ProfileScreen.dart';
import 'package:unimeet_test/Screens/SearchScreen.dart';
import 'package:unimeet_test/Screens/StoreScreen.dart';
import 'package:unimeet_test/UniMeetColors/UniMeetConstants.dart';

class FeedScreen extends StatefulWidget {
  final String CurrentUUID;
  const FeedScreen({Key? key, required this.CurrentUUID}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  int _selectedTab = 0;
  final PageController _pageController = PageController(
    initialPage: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const ScrollPhysics(
          parent: RangeMaintainingScrollPhysics(),
        ),
        controller: _pageController,
        onPageChanged: (page) {
          if (mounted) {
            setState(() {
              _selectedTab = page;
            });
          }
        },
        children: <Widget>[
          HomeScreen(
            CurrentUUID: widget.CurrentUUID,
          ),
          ClubsScreen(
            CurrentUUID: widget.CurrentUUID,
          ),
          ProfileScreen(
            VisitedUId: widget.CurrentUUID,
            CurrentUUID: widget.CurrentUUID,
          ),
          StoreScreen(CurrentUUID: widget.CurrentUUID),
        ],
      ),
      floatingActionButton: _selectedTab == 1 || _selectedTab == 3
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreatePostScreen(
                              CurrentUUID: widget.CurrentUUID,
                            )));
              },
              backgroundColor: Colors.pink,
              child: const Icon(
                Icons.post_add_outlined,
                color: lolaColor,
              ),
            ),
      bottomNavigationBar: CurvedNavigationBar(
        height: 65,
        animationCurve: Curves.easeOutQuad,
        color: lightRoyalBlueColor,
        index: _selectedTab,
        onTap: (value) {
          _selectedTab = value;
          _pageController.animateToPage(
            value,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeIn,
          );
          if (mounted) {
            setState(() {});
          }
        },
        letIndexChange: (index) => true,
        backgroundColor: Color.fromARGB(245, 212, 214, 215),
        buttonBackgroundColor: lightRoyalBlueColor,
        items: const [
          Icon(Icons.home_outlined),
          Icon(Icons.group_outlined),
          Icon(Icons.person_outlined),
          Icon(Icons.attach_money_outlined),
        ],
      ),
    );
  }
}
