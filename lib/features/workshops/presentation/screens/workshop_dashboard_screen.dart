import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:shams_mobile_app/core/presentation/view_status.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/features/posts/domain/entities/post.dart';
import 'package:shams_mobile_app/features/posts/presentation/providers/feed_provider.dart';
import 'package:shams_mobile_app/features/posts/presentation/screens/create_post_screen.dart';
import 'package:shams_mobile_app/features/posts/presentation/screens/edit_post_screen.dart';
import 'package:shams_mobile_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:shams_mobile_app/features/workshops/presentation/providers/my_workshop_provider.dart';
import 'package:shams_mobile_app/features/workshops/presentation/widgets/dashboard/dashboard_header.dart';
import 'package:shams_mobile_app/features/workshops/presentation/widgets/dashboard/dashboard_image_source_sheet.dart';
import 'package:shams_mobile_app/features/workshops/presentation/widgets/dashboard/dashboard_info_section.dart';
import 'package:shams_mobile_app/features/workshops/presentation/widgets/dashboard/dashboard_posts_section.dart';
import 'package:shams_mobile_app/features/workshops/presentation/widgets/dashboard/edit_workshop_sheet.dart';

class WorkshopDashboardScreen extends StatefulWidget {
  const WorkshopDashboardScreen({super.key});

  @override
  State<WorkshopDashboardScreen> createState() =>
      _WorkshopDashboardScreenState();
}

class _WorkshopDashboardScreenState extends State<WorkshopDashboardScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _prevWorkshopId;

  @override
  void initState() {
    super.initState();
    final d = context.read<MyWorkshopProvider>().myWorkshop;
    if (d != null) {
      _prevWorkshopId = d.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<MyWorkshopProvider>().loadPosts(d.id);
      });
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.tajawal()),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── Image pickers ─────────────────────────────────────────────────────────

  Future<void> _pickCoverImage() async {
    showDashboardImageSourceSheet(
      context: context,
      picker: _picker,
      onPicked: (file) async {
        final provider = context.read<MyWorkshopProvider>();
        final ok = await provider.uploadAndSetCover(file.path);
        if (!ok && mounted) {
          _showErrorSnackBar(provider.errorMessage ?? 'تعذر رفع صورة الغلاف');
        }
      },
    );
  }

  Future<void> _pickProfileImage() async {
    showDashboardImageSourceSheet(
      context: context,
      picker: _picker,
      onPicked: (file) async {
        final provider = context.read<MyWorkshopProvider>();
        final ok = await provider.uploadAndSetLogo(file.path);
        if (!ok && mounted) {
          _showErrorSnackBar(provider.errorMessage ?? 'تعذر رفع شعار الورشة');
        }
      },
    );
  }

  Future<void> _pickAndAddImage() async {
    showDashboardImageSourceSheet(
      context: context,
      picker: _picker,
      onPicked: (file) async {
        final provider = context.read<MyWorkshopProvider>();
        final ok = await provider.uploadAndAddGalleryImage(file.path);
        if (!ok && mounted) {
          _showErrorSnackBar(provider.errorMessage ?? 'تعذر رفع الصورة');
        }
      },
    );
  }

  // ── Delete confirmation ───────────────────────────────────────────────────

  void _confirmDelete(Post post) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'حذف المنشور',
            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'هل أنت متأكد من حذف هذا المنشور؟ لا يمكن التراجع عن هذا الإجراء.',
            style: GoogleFonts.tajawal(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'إلغاء',
                style: GoogleFonts.tajawal(
                  color: Theme.of(
                    ctx,
                  ).extension<ShamsExtendedColors>()!.textHint,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'حذف',
                style: GoogleFonts.tajawal(
                  color: Theme.of(ctx).colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    ).then((confirmed) async {
      if (confirmed != true || !mounted) return;
      final workshopProvider = context.read<MyWorkshopProvider>();
      final feedProvider = context.read<FeedProvider>();
      final messenger = ScaffoldMessenger.of(context);
      final errorColor = Theme.of(context).colorScheme.error;

      final deleted = await workshopProvider.deletePost(post.id);
      if (!mounted) return;

      if (deleted) {
        feedProvider.deletePost(post.id);
        messenger.showSnackBar(
          SnackBar(
            content: Text('تم حذف المنشور بنجاح', style: GoogleFonts.tajawal()),
            backgroundColor: errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              workshopProvider.errorMessage ?? 'تعذر حذف المنشور',
              style: GoogleFonts.tajawal(),
            ),
            backgroundColor: errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final workshopState = context.watch<MyWorkshopProvider>();
    final currentUser =
        context.read<ProfileProvider>().currentUserOrPlaceholder;

    // Auto-fetch if user has a workshop but it's not loaded in the provider
    if (currentUser.hasWorkshop &&
        workshopState.myWorkshop == null &&
        workshopState.status == ViewStatus.initial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<MyWorkshopProvider>().load(
              userId: currentUser.id,
              fallbackUsername: currentUser.username ?? '',
            );
      });
    }

    final d = workshopState.myWorkshop;
    if (d != null && d.id != _prevWorkshopId) {
      _prevWorkshopId = d.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<MyWorkshopProvider>().loadPosts(d.id);
      });
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_forward_rounded,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'لوحة تحكم الورشة',
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              DashboardHeader(
                coverUrl: d?.coverUrl,
                logoUrl: d?.logoUrl,
                pendingCoverPath: workshopState.pendingCoverPath,
                pendingLogoPath: workshopState.pendingLogoPath,
                onCoverTap: _pickCoverImage,
                onLogoTap: _pickProfileImage,
              ),
              DashboardInfoSection(
                name: d?.name ?? 'ورشتي على شمس',
                username: d?.username ?? '',
                city: d?.city ?? 'صنعاء',
                galleryUrls: d?.galleryUrls ?? const [],
                pendingGalleryPaths: workshopState.pendingGalleryPaths,
                followersCount: workshopState.followersCount,
                postCount: workshopState.postCount,
                onAddGalleryTap: _pickAndAddImage,
                onRemoveGalleryTap: (i) async {
                  final provider = context.read<MyWorkshopProvider>();
                  final ok = await provider.removeGalleryImageAt(i);
                  if (!ok && mounted) {
                    _showErrorSnackBar(
                      provider.errorMessage ?? 'تعذر حذف الصورة',
                    );
                  }
                },
                onEditTap: () => showEditWorkshopSheet(context),
              ),
              const SizedBox(height: 24),
              DashboardPostsSection(
                posts: workshopState.posts,
                onEditPost: (post) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditPostScreen(post: post),
                    ),
                  );
                },
                onDeletePost: _confirmDelete,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreatePostScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add, size: 24),
                label: Text(
                  'نشر عمل جديد',
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
