import 'package:flutter/material.dart';
import 'package:shams_mobile_app/views/chat/chat_list_screen.dart';
import 'package:shams_mobile_app/views/home.dart';
import 'package:shams_mobile_app/views/user_profile/user_profile_screen.dart';
import 'package:shams_mobile_app/views/workshops/workshops_list_screen.dart';
import 'package:shams_mobile_app/core/widgets/shams_bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    HomeScreen(),
    WorkshopsListScreen(),
    ChatListScreen(), // Following screen not implemented
    UserProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: ShamsBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
