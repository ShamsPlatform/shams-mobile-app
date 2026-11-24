import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/l10n/l10n_mappers.dart';
import 'package:shams_mobile_app/core/presentation/view_status.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/core/widgets/shams_modals.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/review.dart';
import 'package:shams_mobile_app/features/workshops/presentation/providers/workshop_reviews_provider.dart';
import 'package:shams_mobile_app/features/workshops/presentation/widgets/profile/review_editor_sheet.dart';

/// Displays customer reviews and add/edit/delete controls for a workshop.
class WorkshopReviewsSection extends StatelessWidget {
  const WorkshopReviewsSection({
    super.key,
    required this.workshopId,
    required this.workshopName,
    required this.isOwner,
    required this.currentUserId,
    this.onReviewsChanged,
  });

  final String workshopId;
  final String workshopName;
  final bool isOwner;
  final String? currentUserId;
  final VoidCallback? onReviewsChanged;

  Future<void> _openEditor(
    BuildContext context,
    WorkshopReviewsProvider provider, {
    Review? existingReview,
  }) async {
    provider.clearError();
    final saved = await showReviewEditorSheet(
      context: context,
      reviewsProvider: provider,
      workshopId: workshopId,
      workshopName: workshopName,
      initialReview: existingReview,
    );
    if (saved == true) {
      onReviewsChanged?.call();
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WorkshopReviewsProvider provider,
    Review review,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showShamsDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        title: Text(
          l10n.deleteReviewTitle,
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        content: Text(
          l10n.deleteReviewConfirm,
          style: GoogleFonts.tajawal(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel, style: GoogleFonts.tajawal()),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: Text(l10n.delete, style: GoogleFonts.tajawal()),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;
    final deleted = await provider.deleteReview(review.id);
    if (!context.mounted) return;

    if (deleted) {
      onReviewsChanged?.call();
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.reviewDeletedSuccess, style: GoogleFonts.tajawal()),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.localizeErrorMessage(
              provider.errorMessage,
              fallback: l10n.reviewDeleteFailed,
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<ShamsExtendedColors>();
    final provider = context.watch<WorkshopReviewsProvider>();
    final reviews = provider.reviews;
    final existingUserReview = provider.findReviewByUserId(currentUserId);
    final canReview = !isOwner && currentUserId != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ext?.cardSurface ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: ext?.borderLight ?? colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      l10n.reviewsAndOpinions,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.tajawal(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: ShamsColors.solarYellow.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: ShamsColors.solarYellow,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          reviews.isEmpty
                              ? l10n.newLabel
                              : '${provider.averageRating.toStringAsFixed(1)} (${provider.reviewCount})',
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (canReview)
                TextButton.icon(
                  onPressed: () => _openEditor(
                    context,
                    provider,
                    existingReview: existingUserReview,
                  ),
                  icon: Icon(
                    existingUserReview == null
                        ? Icons.rate_review_outlined
                        : Icons.edit_outlined,
                    size: 16,
                  ),
                  label: Text(
                    existingUserReview == null
                        ? l10n.addYourReview
                        : l10n.editMyReview,
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (provider.isLoading && reviews.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (provider.status == ViewStatus.failure && reviews.isEmpty)
            Column(
              children: [
                Text(
                  l10n.localizeErrorMessage(
                    provider.errorMessage,
                    fallback: l10n.failedToLoadReviews,
                  ),
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    color: colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => provider.load(workshopId),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(
                    l10n.retry,
                    style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            )
          else if (reviews.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  Icon(
                    Icons.reviews_outlined,
                    size: 32,
                    color: ext?.textHint ?? ShamsColors.textHint,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.noReviewsYet,
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (canReview) ...[
                    const SizedBox(height: 4),
                    Text(
                      l10n.beFirstToReview,
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        color: ext?.textHint ?? ShamsColors.textHint,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            )
          else
            Column(
              children: [
                for (var i = 0; i < reviews.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 20,
                      color: ext?.dividerLight ?? colorScheme.outlineVariant,
                    ),
                  _ReviewTile(
                    review: reviews[i],
                    isAuthor: currentUserId != null &&
                        reviews[i].reviewer.id == currentUserId,
                    isSubmitting: provider.isSubmitting,
                    onEdit: () => _openEditor(
                      context,
                      provider,
                      existingReview: reviews[i],
                    ),
                    onDelete: () => _confirmDelete(
                      context,
                      provider,
                      reviews[i],
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.review,
    required this.isAuthor,
    required this.isSubmitting,
    required this.onEdit,
    required this.onDelete,
  });

  final Review review;
  final bool isAuthor;
  final bool isSubmitting;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  bool get _hasValidAvatar {
    final url = review.reviewer.profileImageUrl?.trim() ?? '';
    return url.startsWith('http://') || url.startsWith('https://');
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '${local.year}/$m/$d';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<ShamsExtendedColors>();
    final displayName = review.reviewer.name.trim().isNotEmpty
        ? review.reviewer.name
        : (review.reviewer.username ?? l10n.userFallback);
    final filledStars = review.rating.round().clamp(0, 5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ext?.avatarFallbackBg ?? ShamsColors.avatarFallbackBg,
              ),
              clipBehavior: Clip.antiAlias,
              child: _hasValidAvatar
                  ? Image.network(
                      review.reviewer.profileImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.person,
                        size: 20,
                        color: ShamsColors.primaryBlue,
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 20,
                      color: ShamsColors.primaryBlue,
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (index) => Icon(
                          index < filledStars
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 14,
                          color: index < filledStars
                              ? ShamsColors.solarYellow
                              : ext?.textHint ?? ShamsColors.textHint,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _formatDate(review.createdAt),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.tajawal(
                            fontSize: 11,
                            color: ext?.textHint ?? ShamsColors.textHint,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isAuthor) ...[
              IconButton(
                tooltip: l10n.editReview,
                onPressed: isSubmitting ? null : onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                tooltip: l10n.deleteReviewTitle,
                onPressed: isSubmitting ? null : onDelete,
                icon: Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: colorScheme.error,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ],
        ),
        if (review.comment.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: GoogleFonts.tajawal(
              fontSize: 13,
              height: 1.5,
              color: colorScheme.onSurface.withValues(alpha: 0.9),
            ),
          ),
        ],
      ],
    );
  }
}
