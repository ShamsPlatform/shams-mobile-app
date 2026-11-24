import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/core/widgets/shams_bottom_nav_bar.dart';
import 'package:shams_mobile_app/core/widgets/shams_drawer.dart';
import 'package:shams_mobile_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:shams_mobile_app/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:shams_mobile_app/features/posts/presentation/screens/home_screen.dart';
import 'package:shams_mobile_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:shams_mobile_app/features/profile/presentation/screens/about_shams_screen.dart';
import 'package:shams_mobile_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:shams_mobile_app/features/profile/presentation/screens/user_profile_screen.dart';
import 'package:shams_mobile_app/features/workshops/presentation/screens/workshop_dashboard_screen.dart';
import 'package:shams_mobile_app/features/workshops/presentation/screens/workshops_list_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  /// Root scaffold key for child screens to open the root drawer if needed.
  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pages = [
      const HomeScreen(),
      const WorkshopsListScreen(),
      ChatListScreen(
        onExploreWorkshops: () {
          setState(() {
            _currentIndex = 1;
          });
        },
      ),
      const UserProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final currentUser = profileProvider.currentUserOrPlaceholder;

    return Scaffold(
      key: MainScreen.scaffoldKey,
      drawer: ShamsDrawer(
        activeIndex: _currentIndex,
        currentUser: currentUser,
        onTabSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        onEditProfileTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
        ),
        onAboutTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AboutShamsScreen()),
        ),
        onWorkshopDashboardTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const WorkshopDashboardScreen(),
          ),
        ),
        onSignOut: () => context.read<AuthProvider>().signOut(),
      ),
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
