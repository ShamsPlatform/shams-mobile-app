import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/core/di/injection.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/l10n/l10n_mappers.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/core/widgets/shams_modals.dart';
import 'package:shams_mobile_app/features/posts/presentation/providers/feed_provider.dart';
import 'package:shams_mobile_app/features/posts/presentation/providers/post_editor_provider.dart';
import 'package:shams_mobile_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:shams_mobile_app/features/workshops/presentation/providers/my_workshop_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MediaFile — نموذج للملفات المرفقة
// ─────────────────────────────────────────────────────────────────────────────

class MediaFile {
  final String path;
  final bool isVideo;
  final bool isAsset;

  MediaFile({required this.path, this.isVideo = false, this.isAsset = false});
}

// ─────────────────────────────────────────────────────────────────────────────
// CreatePostScreen — شاشة إضافة عمل جديد
// ─────────────────────────────────────────────────────────────────────────────

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  // ── State ──────────────────────────────────────────────────────────────────

  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  /// قائمة تمثّل الملفات المرفقة (صور أو فيديوهات)
  final List<MediaFile> _attachments = [];

  bool _isHighlighted = true;

  // ── Dispose ────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  /// دالة لاختيار الصور أو الفيديوهات
  Future<void> _pickMedia() async {
    final l10n = AppLocalizations.of(context)!;
    showShamsDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text(
          l10n.addAttachment,
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        content: Text(
          l10n.chooseFileType,
          style: GoogleFonts.tajawal(),
        ),
        actions: [
          TextButton(
            onPressed: () => _handlePick(ImageSource.gallery, false),
            child: Text(
              l10n.galleryPhotos,
              style: GoogleFonts.tajawal(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          TextButton(
            onPressed: () => _handlePick(ImageSource.gallery, true),
            child: Text(
              l10n.galleryVideo,
              style: GoogleFonts.tajawal(color: Colors.purple),
            ),
          ),
          TextButton(
            onPressed: () => _handlePick(ImageSource.camera, false),
            child: Text(
              l10n.camera,
              style: GoogleFonts.tajawal(color: Colors.orange),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: GoogleFonts.tajawal(color: Theme.of(context).extension<ShamsExtendedColors>()!.textHint),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePick(ImageSource source, bool isVideo) async {
    final l10n = AppLocalizations.of(context)!;
    Navigator.pop(context);

    try {
      XFile? file;
      if (isVideo) {
        file = await _picker.pickVideo(source: source);
      } else {
        file = await _picker.pickImage(source: source);
      }

      if (file != null) {
        setState(() {
          _attachments.add(MediaFile(path: file!.path, isVideo: isVideo));
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.cameraNotSupported,
          ),
        ),
      );
    }
  }

  void _removeAttachment(int index) {
    setState(() => _attachments.removeAt(index));
  }

  Future<void> _publish(BuildContext editorContext) async {
    final l10n = AppLocalizations.of(context)!;
    if (_contentController.text.trim().isEmpty && _attachments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.addPostContentError,
            style: GoogleFonts.tajawal(),
          ),
        ),
      );
      return;
    }

    final myWorkshop = context.read<MyWorkshopProvider>().myWorkshop;
    final currentUser = context.read<ProfileProvider>().currentUserOrPlaceholder;
    final workshopId = myWorkshop?.id ?? currentUser.id;
    final editor = editorContext.read<PostEditorProvider>();

    showShamsDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final newPost = await editor.create(
      workshopId: workshopId,
      textDetails: _contentController.text.trim(),
      imagePaths: _attachments.map((a) => a.path).toList(),
      isHighlighted: _isHighlighted,
    );

    if (!mounted) return;
    Navigator.pop(context); // Dismiss loading

    if (newPost != null) {
      context.read<MyWorkshopProvider>().addPost(newPost);
      context.read<FeedProvider>().addPost(newPost);
      Navigator.pop(context); // Go back
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.publishError(l10n.localizeErrorMessage(editor.errorMessage, fallback: '')),
            style: GoogleFonts.tajawal(),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ChangeNotifierProvider(
      create: (_) => sl<PostEditorProvider>(),
      builder: (editorContext, _) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: _buildAppBar(l10n),
        body: Column(
          children: [
            const Divider(
              height: 1,
              thickness: 1,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. قسم رفع الصور والفيديو
                    _buildUploadSection(l10n),

                    const SizedBox(height: 24),

                    // 2. قائمة الملفات المرفقة
                    if (_attachments.isNotEmpty) _buildAttachmentsList(),

                    const SizedBox(height: 24),

                    // 3. حقل تفاصيل المنشور
                    _buildContentField(l10n),

                    const SizedBox(height: 24),

                    // 4. خيار التمييز
                    _buildHighlightToggle(l10n),

                    const SizedBox(height: 12),

                    // 5. تلميح
                    _buildHint(l10n),
                  ],
                ),
              ),
            ),
            _buildPublishButton(editorContext, l10n),
          ],
        ),
      ),
    );
  }

  // ── Widgets ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
        l10n.addNewWork,
        style: GoogleFonts.tajawal(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back_rounded,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildUploadSection(AppLocalizations l10n) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _pickMedia,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).extension<ShamsExtendedColors>()!.borderLight, width: 1.5),
          ),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 28,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  PositionedDirectional(
                    bottom: 2,
                    start: 2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add,
                        size: 14,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                l10n.attachMedia,
                style: GoogleFonts.tajawal(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.documentSolarAchievements,
                style: GoogleFonts.tajawal(fontSize: 13, color: Theme.of(context).extension<ShamsExtendedColors>()!.textHint),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentsList() {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _attachments.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _AttachmentThumbnail(
            media: _attachments[index],
            onRemove: () => _removeAttachment(index),
          );
        },
      ),
    );
  }

  Widget _buildContentField(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.postDetailsLabel,
          style: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).extension<ShamsExtendedColors>()!.borderLight),
          ),
          child: TextField(
            controller: _contentController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: l10n.writePostDetailsHint,
              hintStyle: GoogleFonts.tajawal(
                color: Theme.of(context).extension<ShamsExtendedColors>()!.textHint,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightToggle(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).extension<ShamsExtendedColors>()!.backgroundLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.highlightPostInProfile,
                  style: GoogleFonts.tajawal(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.highlightPostSubtitle,
                  style: GoogleFonts.tajawal(fontSize: 13, color: Theme.of(context).extension<ShamsExtendedColors>()!.textHint),
                ),
              ],
            ),
          ),
          Switch(
            value: _isHighlighted,
            onChanged: (val) => setState(() => _isHighlighted = val),
            activeThumbColor: Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildHint(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: Theme.of(context).extension<ShamsExtendedColors>()!.textHint),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.highlightHint,
              style: GoogleFonts.tajawal(fontSize: 11, color: Theme.of(context).extension<ShamsExtendedColors>()!.textHint),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublishButton(BuildContext editorContext, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: () => _publish(editorContext),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            l10n.publishWorkNow,
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AttachmentThumbnail — مصغرة للمرفق (صورة أو فيديو)
// ─────────────────────────────────────────────────────────────────────────────

class _AttachmentThumbnail extends StatelessWidget {
  final MediaFile media;
  final VoidCallback onRemove;

  const _AttachmentThumbnail({required this.media, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 85,
            height: 85,
            child: media.isVideo
                // ── مصغّرة الفيديو ──────────────────────────────────────────
                ? Container(
                    color: const Color(0xFF1A1A2E),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        const Center(
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        PositionedDirectional(
                          bottom: 4,
                          end: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.videocam_rounded,
                                    color: Colors.white, size: 10),
                                const SizedBox(width: 2),
                                Text(
                                  l10n.video,
                                  style: GoogleFonts.tajawal(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                // ── مصغّرة الصورة ────────────────────────────────────────────
                : Image.file(
                    File(media.path),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(
                          color: Theme.of(context).extension<ShamsExtendedColors>()!.borderLight,
                          child: Icon(Icons.broken_image,
                              color: Theme.of(context).extension<ShamsExtendedColors>()!.textHint),
                        ),
                  ),
          ),
        ),
        PositionedDirectional(
          top: -5,
          start: -5,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
