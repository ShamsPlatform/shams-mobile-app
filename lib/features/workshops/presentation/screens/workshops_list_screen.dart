import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:shams_mobile_app/core/constants/app_constants.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/core/widgets/appbar.dart';
import 'package:shams_mobile_app/core/widgets/city_filter.dart';
import 'package:shams_mobile_app/features/workshops/presentation/widgets/workshop_card.dart';
import 'package:shams_mobile_app/core/widgets/inline_search_bar.dart';
import 'package:shams_mobile_app/features/workshops/presentation/constants/workshop_assets.dart';
import 'package:shams_mobile_app/features/workshops/presentation/providers/workshops_provider.dart';
import 'package:shams_mobile_app/features/notifications/presentation/providers/notification_provider.dart';
import 'package:shams_mobile_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:shams_mobile_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:shams_mobile_app/features/profile/presentation/screens/about_shams_screen.dart';
import 'package:shams_mobile_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:shams_mobile_app/features/workshops/presentation/screens/workshop_dashboard_screen.dart';
import 'package:shams_mobile_app/features/workshops/presentation/screens/workshop_profile_screen.dart';
import 'package:shams_mobile_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:shams_mobile_app/core/widgets/shams_drawer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WorkshopsListScreen — قائمة الورش العامة
//
// • Reads live data from WorkshopProvider via context.watch() in build().
// • All mutations (toggleFollow) use context.read() inside callbacks.
// • No Consumer widgets used anywhere.
// ─────────────────────────────────────────────────────────────────────────────

class WorkshopsListScreen extends StatefulWidget {
  const WorkshopsListScreen({super.key});

  @override
  State<WorkshopsListScreen> createState() => _WorkshopsListScreenState();
}

class _WorkshopsListScreenState extends State<WorkshopsListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  // Local UI state — search query and selected city filters.
  List<String> _selectedCities = [];
  final List<String> _selectedServices = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 250) {
      context.read<WorkshopsProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    // ── Single source of truth: watch provider for live updates ──────────────
    final workshopsProvider = context.watch<WorkshopsProvider>();
    final workshops = workshopsProvider.workshops;

    // ── Smart filter: apply city + search query ───────────────────────────────
    final filteredWorkshops = workshops.where((workshop) {
      final matchesCity =
          _selectedCities.isEmpty || _selectedCities.contains(workshop.city);
      final matchesSearch = _searchQuery.isEmpty ||
          workshop.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesService = _selectedServices.isEmpty ||
          workshop.serviceTypes.any((s) => _selectedServices.contains(s));
      return matchesCity && matchesSearch && matchesService;
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: ShamsDrawer(
          activeIndex: 1,
          currentUser: context.watch<ProfileProvider>().currentUserOrPlaceholder,
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
        backgroundColor: Theme.of(context).extension<ShamsExtendedColors>()!.backgroundLight,

        // ── الشريط العلوي ──────────────────────────────────────────────────
        appBar: ShamsPlatformAppBar(
          unreadNotifications:
              context.select<NotificationProvider, int>((p) => p.unreadCount),
          onMenuTap: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          onNotificationTap: () {
            context.read<NotificationProvider>().markAllAsRead();
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const NotificationsScreen()),
            );
          },
          // onDarkModeTap omitted — AppBar uses ThemeProvider.toggleTheme() by default
        ),

        body: Column(
          children: [
            // ── شريط البحث ──────────────────────────────────────────────────
            InlineSearchBar(
              hintText: 'ابحث عن الورشة المفضلة...',
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),

            // ── فلتر المدن ──────────────────────────────────────────────────
            Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: CityMultiSelectFilter(
                onSelectionChanged: (selectedCities) {
                  setState(() {
                    _selectedCities = selectedCities;
                  });
                },
              ),
            ),

            // ── فلتر الخدمات ────────────────────────────────────────────────
            Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: ShamsConstants.solarServiceTypes.length,
                  itemBuilder: (context, index) {
                    final service = ShamsConstants.solarServiceTypes[index];
                    final isSelected = _selectedServices.contains(service);
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: FilterChip(
                          label: Text(
                            service,
                            style: GoogleFonts.tajawal(
                              fontSize: 13,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onSecondary
                                  : Theme.of(context)
                                      .extension<ShamsExtendedColors>()!
                                      .textHint,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                _selectedServices.add(service);
                              } else {
                                _selectedServices.remove(service);
                              }
                            });
                          },
                          selectedColor: Theme.of(context).colorScheme.secondary,
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          checkmarkColor: Theme.of(context).colorScheme.onSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context)
                                      .extension<ShamsExtendedColors>()!
                                      .borderLight,
                            ),
                          ),
                      ),
                    );
                  },
                ),
              ),
            ),

            Divider(height: 1, thickness: 1, color: Theme.of(context).extension<ShamsExtendedColors>()!.dividerLight),

            // ── قائمة الورش ────────────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context.read<WorkshopsProvider>().load(),
                child: workshopsProvider.isLoading && workshops.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 160),
                          Center(child: CircularProgressIndicator()),
                        ],
                      )
                    : filteredWorkshops.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 160),
                              Center(
                                child: Text(
                                  'لا توجد ورش في المحافظات المحددة.',
                                  style: GoogleFonts.tajawal(
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(top: 8, bottom: 20),
                            itemCount: filteredWorkshops.length +
                                (workshopsProvider.isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= filteredWorkshops.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              final workshop = filteredWorkshops[index];
                              return WorkshopCard(
                          username: workshop.name,
                          userHandle: workshop.handle,
                          imagePath: workshop.logoUrl ?? kDefaultWorkshopLogoAsset,
                          coverImagePath:
                              workshop.coverUrl ?? kDefaultWorkshopCoverAsset,
                          cityName: workshop.city,
                          rating: workshop.rating,
                          // isFollowing reflects live provider state via watch()
                          isFollowing: workshop.isFollowing,
                          // context.read() inside callback — correct usage.
                          onFollowToggle: (_) async {
                            final provider = context.read<WorkshopsProvider>();
                            final messenger = ScaffoldMessenger.of(context);
                            final errorColor =
                                Theme.of(context).colorScheme.error;
                            final ok = await provider.toggleFollow(workshop.id);
                            if (!ok && mounted) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    provider.errorMessage ??
                                        'تعذر تحديث المتابعة',
                                    style: GoogleFonts.tajawal(),
                                  ),
                                  backgroundColor: errorColor,
                                ),
                              );
                            }
                          },
                          onEnterTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  WorkshopProfile(workshopId: workshop.id),
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
