import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/l10n/l10n_mappers.dart';
import 'package:shams_mobile_app/core/presentation/view_status.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/core/widgets/shams_modals.dart';
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
    final l10n = AppLocalizations.of(context)!;
    showDashboardImageSourceSheet(
      context: context,
      picker: _picker,
      onPicked: (file) async {
        final provider = context.read<MyWorkshopProvider>();
        final ok = await provider.uploadAndSetCover(file.path);
        if (!ok && mounted) {
          _showErrorSnackBar(
            l10n.localizeErrorMessage(
              provider.errorMessage,
              fallback: l10n.uploadCoverFailed,
            ),
          );
        }
      },
    );
  }

  Future<void> _pickProfileImage() async {
    final l10n = AppLocalizations.of(context)!;
    showDashboardImageSourceSheet(
      context: context,
      picker: _picker,
      onPicked: (file) async {
        final provider = context.read<MyWorkshopProvider>();
        final ok = await provider.uploadAndSetLogo(file.path);
        if (!ok && mounted) {
          _showErrorSnackBar(
            l10n.localizeErrorMessage(
              provider.errorMessage,
              fallback: l10n.uploadLogoFailed,
            ),
          );
        }
      },
    );
  }

  Future<void> _pickAndAddImage() async {
    final l10n = AppLocalizations.of(context)!;
    showDashboardImageSourceSheet(
      context: context,
      picker: _picker,
      onPicked: (file) async {
        final provider = context.read<MyWorkshopProvider>();
        final ok = await provider.uploadAndAddGalleryImage(file.path);
        if (!ok && mounted) {
          _showErrorSnackBar(
            l10n.localizeErrorMessage(
              provider.errorMessage,
              fallback: l10n.uploadImageFailed,
            ),
          );
        }
      },
    );
  }

  // ── Delete confirmation ───────────────────────────────────────────────────

  void _confirmDelete(Post post) {
    final l10n = AppLocalizations.of(context)!;
    showShamsDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          l10n.deletePostTitle,
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        content: Text(
          l10n.deletePostConfirm,
          style: GoogleFonts.tajawal(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l10n.cancel,
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
              l10n.delete,
              style: GoogleFonts.tajawal(
                color: Theme.of(ctx).colorScheme.error,
              ),
            ),
          ),
        ],
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
            content: Text(l10n.postDeletedSuccess, style: GoogleFonts.tajawal()),
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
              l10n.localizeErrorMessage(
                workshopProvider.errorMessage,
                fallback: l10n.deletePostFailed,
              ),
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
    final l10n = AppLocalizations.of(context)!;
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

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.workshopDashboard,
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
              name: d?.name ?? l10n.myWorkshopOnShams,
              username: d?.username ?? '',
              city: l10n.localizeCity(d?.city ?? 'صنعاء'),
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
                    l10n.localizeErrorMessage(
                      provider.errorMessage,
                      fallback: l10n.deleteImageFailed,
                    ),
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
                l10n.publishNewWork,
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
