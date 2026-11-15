import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/core/widgets/inline_search_bar.dart';
import 'package:shams_mobile_app/core/widgets/primary_button.dart';
import 'package:shams_mobile_app/features/posts/presentation/providers/feed_provider.dart';
import 'package:shams_mobile_app/features/workshops/presentation/providers/workshops_provider.dart';
import 'package:shams_mobile_app/features/workshops/presentation/widgets/profile/maintenance_request_sheet.dart';
import 'package:shams_mobile_app/features/workshops/presentation/widgets/profile/workshop_profile_header.dart';
import 'package:shams_mobile_app/features/workshops/presentation/widgets/profile/workshop_profile_info.dart';
import 'package:shams_mobile_app/features/workshops/presentation/widgets/profile/workshop_work_log_section.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WorkshopProfile — صفحة الملف الشخصي للورشة
//
// • Accepts [workshopId] in its constructor.
// • Watches [WorkshopsProvider] for live updates to the workshop details and follow status.
// • Dynamically connects to ChatProvider via maintenance request sheet.
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

  Future<void> _toggleFollow() async {
    final provider = context.read<WorkshopsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;
    final ok = await provider.toggleFollow(widget.workshopId);
    if (!ok && mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'تعذر تحديث المتابعة',
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

    if (workshop == null) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
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
              'الورشة المطلوبة غير متوفرة حالياً.',
              style: GoogleFonts.tajawal(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      );
    }

    final isFollowing = workshop.isFollowing;
    final feedPosts = context.watch<FeedProvider>().posts;
    final workshopPosts =
        feedPosts.where((post) => post.workshopId == workshop.id).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
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
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
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
                        'بحث',
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
            title: 'طلب خدمة صيانة الآن',
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
                    hintText: 'ابحث في الورشة...',
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
              WorkshopProfileInfo(
                workshop: workshop,
                isFollowing: isFollowing,
                onToggleFollow: _toggleFollow,
              ),
              const SizedBox(height: 25),
              WorkshopWorkLogSection(posts: workshopPosts),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}
