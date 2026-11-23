import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/core/di/injection.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/l10n/l10n_mappers.dart';
import 'package:shams_mobile_app/core/presentation/view_status.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/core/widgets/inline_search_bar.dart';
import 'package:shams_mobile_app/core/widgets/primary_button.dart';
import 'package:shams_mobile_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:shams_mobile_app/features/maintenance/presentation/providers/maintenance_request_provider.dart';
import 'package:shams_mobile_app/features/posts/presentation/providers/feed_provider.dart';
import 'package:shams_mobile_app/features/workshops/presentation/providers/workshop_reviews_provider.dart';
import 'package:shams_mobile_app/features/workshops/presentation/providers/workshops_provider.dart';
import 'package:shams_mobile_app/features/workshops/presentation/widgets/profile/maintenance_request_sheet.dart';
import 'package:shams_mobile_app/features/workshops/presentation/widgets/profile/workshop_profile_header.dart';
import 'package:shams_mobile_app/features/workshops/presentation/widgets/profile/workshop_profile_info.dart';
import 'package:shams_mobile_app/features/workshops/presentation/widgets/profile/workshop_reviews_section.dart';
import 'package:shams_mobile_app/features/workshops/presentation/widgets/profile/workshop_work_log_section.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WorkshopProfile — صفحة الملف الشخصي للورشة
//
// • Accepts [workshopId] in its constructor.
// • Watches [WorkshopsProvider] for live updates to the workshop details and follow status.
// • Connects to MaintenanceRequestProvider via maintenance request sheet.
// ─────────────────────────────────────────────────────────────────────────────

class WorkshopProfile extends StatefulWidget {
  final String workshopId;

  const WorkshopProfile({
    super.key,
    required this.workshopId,
  });

  @override
  State<WorkshopProfile> createState() => _WorkshopProfileState();
}

class _WorkshopProfileState extends State<WorkshopProfile> {
  bool _isSearching = false;
  late final WorkshopReviewsProvider _reviewsProvider;

  @override
  void initState() {
    super.initState();
    _reviewsProvider = sl<WorkshopReviewsProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReviews();
    });
  }

  @override
  void dispose() {
    _reviewsProvider.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    if (!mounted) return;
    final workshop =
        context.read<WorkshopsProvider>().getWorkshopById(widget.workshopId);
    await _reviewsProvider.load(
      widget.workshopId,
      initialReviews: workshop?.reviews ?? const [],
    );
    if (!mounted || _reviewsProvider.status != ViewStatus.success) return;
    _syncWorkshopReviewSummary();
  }

  void _syncWorkshopReviewSummary() {
    if (!mounted) return;
    context.read<WorkshopsProvider>().updateReviewSummary(
          widget.workshopId,
          rating: _reviewsProvider.averageRating,
          reviewCount: _reviewsProvider.reviewCount,
        );
  }

  Future<void> _toggleFollow() async {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<WorkshopsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;
    final ok = await provider.toggleFollow(widget.workshopId);
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
  }

  @override
  Widget build(BuildContext context) {
    final workshopsProvider = context.watch<WorkshopsProvider>();
    final workshop = workshopsProvider.getWorkshopById(widget.workshopId);
    final l10n = AppLocalizations.of(context)!;

    if (workshop == null) {
      return Scaffold(
        backgroundColor: Theme.of(context)
            .extension<ShamsExtendedColors>()!
            .backgroundLight,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0.5,
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        body: Center(
          child: Text(
            l10n.workshopUnavailable,
            style: GoogleFonts.tajawal(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      );
    }

    final isFollowing = workshop.isFollowing;
    final feedPosts = context.watch<FeedProvider>().posts;
    final workshopPosts =
        feedPosts.where((post) => post.workshopId == workshop.id).toList();
    final currentUserId = context.select<AuthProvider, String?>(
      (auth) => auth.currentUser?.id,
    );
    final isOwner = currentUserId != null && workshop.ownerId == currentUserId;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => sl<MaintenanceRequestProvider>(),
        ),
        ChangeNotifierProvider.value(
          value: _reviewsProvider,
        ),
      ],
      child: Builder(
        builder: (context) => Scaffold(
        backgroundColor: Theme.of(context)
            .extension<ShamsExtendedColors>()!
            .backgroundLight,
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          title: Text(
            workshop.name,
            style: GoogleFonts.tajawal(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0.5,
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (value) {
                if (value == 'search') {
                  setState(() {
                    _isSearching = true;
                  });
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'search',
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.search,
                        style: GoogleFonts.tajawal(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: CustomSolidButton(
            title: l10n.requestMaintenanceNow,
            onPressed: () => showMaintenanceRequestSheet(context, workshop),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: SingleChildScrollView(
          child: Column(
            children: [
              if (_isSearching)
                SafeArea(
                  bottom: false,
                  child: InlineSearchBar(
                    hintText: l10n.searchInWorkshopHint,
                    onChanged: (val) {},
                    onClose: () {
                      setState(() {
                        _isSearching = false;
                      });
                    },
                  ),
                ),
              WorkshopProfileHeader(workshop: workshop),
              const SizedBox(height: 55),
              Consumer<WorkshopReviewsProvider>(
                builder: (context, reviewsProvider, _) {
                  final liveWorkshop =
                      reviewsProvider.status == ViewStatus.success
                          ? workshop.copyWith(
                              rating: reviewsProvider.averageRating,
                              reviewCount: reviewsProvider.reviewCount,
                            )
                          : workshop;
                  return WorkshopProfileInfo(
                    workshop: liveWorkshop,
                    isFollowing: isFollowing,
                    onToggleFollow: _toggleFollow,
                  );
                },
              ),
              const SizedBox(height: 25),
              WorkshopReviewsSection(
                workshopId: workshop.id,
                workshopName: workshop.name,
                isOwner: isOwner,
                currentUserId: currentUserId,
                onReviewsChanged: _syncWorkshopReviewSummary,
              ),
              const SizedBox(height: 25),
              WorkshopWorkLogSection(posts: workshopPosts),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
