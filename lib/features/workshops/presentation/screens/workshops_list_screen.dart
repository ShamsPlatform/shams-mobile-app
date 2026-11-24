import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:shams_mobile_app/app/main_screen.dart';
import 'package:shams_mobile_app/core/constants/app_constants.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/l10n/l10n_mappers.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/core/widgets/appbar.dart';
import 'package:shams_mobile_app/core/widgets/city_filter.dart';
import 'package:shams_mobile_app/core/widgets/inline_search_bar.dart';
import 'package:shams_mobile_app/features/notifications/presentation/providers/notification_provider.dart';
import 'package:shams_mobile_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:shams_mobile_app/features/workshops/presentation/constants/workshop_assets.dart';
import 'package:shams_mobile_app/features/workshops/presentation/providers/workshops_provider.dart';
import 'package:shams_mobile_app/features/workshops/presentation/screens/workshop_profile_screen.dart';
import 'package:shams_mobile_app/features/workshops/presentation/widgets/workshop_card.dart';

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
    final l10n = AppLocalizations.of(context)!;

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

    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).extension<ShamsExtendedColors>()!.backgroundLight,

        // ── الشريط العلوي ──────────────────────────────────────────────────
        appBar: ShamsPlatformAppBar(
          unreadNotifications:
              context.select<NotificationProvider, int>((p) => p.unreadCount),
          onMenuTap: () {
            final rootScaffold = Scaffold.maybeOf(context);
            if (rootScaffold != null && rootScaffold.hasDrawer) {
              rootScaffold.openDrawer();
            } else if (MainScreen.scaffoldKey.currentState?.hasDrawer ?? false) {
              MainScreen.scaffoldKey.currentState?.openDrawer();
            } else {
              _scaffoldKey.currentState?.openDrawer();
            }
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
              hintText: l10n.searchWorkshopHint,
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
              padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
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
              padding: const EdgeInsetsDirectional.only(bottom: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    for (int index = 0;
                        index < ShamsConstants.solarServiceTypes.length;
                        index++) ...[
                      if (index > 0) const SizedBox(width: 8),
                      Builder(
                        builder: (context) {
                          final service =
                              ShamsConstants.solarServiceTypes[index];
                          final isSelected =
                              _selectedServices.contains(service);
                          return _ServiceFilterChip(
                            label: l10n.localizeServiceType(service),
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedServices.remove(service);
                                } else {
                                  _selectedServices.add(service);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ],
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
                                  l10n.noWorkshopsInCities,
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
                          heroTag: 'workshop-avatar-${workshop.id}',
                          username: workshop.name,
                          userHandle: workshop.handle,
                          imagePath: workshop.logoUrl ?? kDefaultWorkshopLogoAsset,
                          coverImagePath:
                              workshop.coverUrl ?? kDefaultWorkshopCoverAsset,
                          cityName: l10n.localizeCity(workshop.city),
                          rating: workshop.rating,
                          reviewCount: workshop.reviewCount,
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
                                    l10n.localizeErrorMessage(
                                      provider.errorMessage,
                                      fallback: l10n.followToggleError,
                                    ),
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
      );
  }
}

class _ServiceFilterChip extends StatefulWidget {
  const _ServiceFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_ServiceFilterChip> createState() => _ServiceFilterChipState();
}

class _ServiceFilterChipState extends State<_ServiceFilterChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;
    final isSelected = widget.isSelected;

    return Listener(
      onPointerDown: (_) {
        if (mounted) setState(() => _isPressed = true);
      },
      onPointerUp: (_) {
        if (mounted && _isPressed) setState(() => _isPressed = false);
      },
      onPointerCancel: (_) {
        if (mounted && _isPressed) setState(() => _isPressed = false);
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.secondary : ext.chipBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? colorScheme.secondary : ext.borderLight,
              width: 1.2,
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                constraints: const BoxConstraints(minHeight: 40),
                alignment: AlignmentDirectional.center,
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: colorScheme.onSecondary,
                        ),
                        const SizedBox(width: 6),
                      ],
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        style: GoogleFonts.tajawal(
                          fontSize: 13,
                          color: isSelected
                              ? colorScheme.onSecondary
                              : colorScheme.onSurfaceVariant,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                        child: Text(widget.label),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

