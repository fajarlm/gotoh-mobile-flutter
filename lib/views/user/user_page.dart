import 'package:flutter/material.dart';
import 'package:fe_mobile/views/user/home_page.dart';
import 'package:fe_mobile/views/user/my_community.dart';
import 'package:fe_mobile/views/user/health_page.dart';
import 'package:fe_mobile/views/user/profile_page.dart';
import 'package:fe_mobile/widget/custom_bottom_bar_user.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => UserPageState();

  static UserPageState? of(BuildContext context) {
    return context.findAncestorStateOfType<UserPageState>();
  }
}

class UserPageState extends State<UserPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    MyCommunityPage(),
    HealthPage(),
    ProfilePage(),
  ];

  void setTab(int index) {
    if (index >= 0 && index < _pages.length) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomBarUser(
        currentIndex: _currentIndex,
        onTap: setTab,
      ),
    );
  }
}
