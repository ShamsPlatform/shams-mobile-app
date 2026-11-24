import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/l10n/l10n_mappers.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/core/widgets/outlined_button.dart';
import 'package:shams_mobile_app/core/widgets/primary_button.dart';
import 'package:shams_mobile_app/core/widgets/shams_modals.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/review.dart';
import 'package:shams_mobile_app/features/workshops/presentation/providers/workshop_reviews_provider.dart';

/// Opens a bottom sheet for creating or editing a workshop review.
///
/// Returns `true` when the review was saved successfully.
Future<bool?> showReviewEditorSheet({
  required BuildContext context,
  required WorkshopReviewsProvider reviewsProvider,
  required String workshopId,
  required String workshopName,
  Review? initialReview,
}) {
  return showShamsModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider.value(
      value: reviewsProvider,
      child: _ReviewEditorSheet(
        workshopId: workshopId,
        workshopName: workshopName,
        initialReview: initialReview,
      ),
    ),
  );
}

class _ReviewEditorSheet extends StatefulWidget {
  const _ReviewEditorSheet({
    required this.workshopId,
    required this.workshopName,
    this.initialReview,
  });

  final String workshopId;
  final String workshopName;
  final Review? initialReview;

  @override
  State<_ReviewEditorSheet> createState() => _ReviewEditorSheetState();
}

class _ReviewEditorSheetState extends State<_ReviewEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _commentController;
  late int _selectedRating;

  bool get _isEditing => widget.initialReview != null;

  @override
  void initState() {
    super.initState();
    _selectedRating =
        (widget.initialReview?.rating.round() ?? 5).clamp(1, 5);
    _commentController = TextEditingController(
      text: widget.initialReview?.comment ?? '',
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _ratingLabel(int rating, AppLocalizations l10n) {
    return switch (rating) {
      1 => l10n.ratingPoor,
      2 => l10n.ratingFair,
      3 => l10n.ratingGood,
      4 => l10n.ratingVeryGood,
      _ => l10n.ratingExcellent,
    };
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<WorkshopReviewsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final ok = _isEditing
        ? await provider.updateReview(
            reviewId: widget.initialReview!.id,
            rating: _selectedRating.toDouble(),
            comment: _commentController.text,
          )
        : await provider.addReview(
            workshopId: widget.workshopId,
            rating: _selectedRating.toDouble(),
            comment: _commentController.text,
          );

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? l10n.reviewUpdatedSuccess
                : l10n.reviewPublishedSuccess,
            style: GoogleFonts.tajawal(),
          ),
          backgroundColor: ShamsColors.verifiedGreen,
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Consumer<WorkshopReviewsProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: EdgeInsetsDirectional.fromSTEB(20, 12, 20, 20 + bottomInset),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: ext?.handleBar ?? ShamsColors.handleBar,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isEditing
                        ? l10n.editYourReviewTitle
                        : l10n.addWorkshopReviewTitle,
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.workshopName,
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      color: ext?.textHint ?? ShamsColors.textHint,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      color: ext?.backgroundLight ?? colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: ext?.borderLight ?? colorScheme.outlineVariant,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final starValue = index + 1;
                            final isSelected = starValue <= _selectedRating;
                            return Flexible(
                              child: IconButton(
                                tooltip: l10n.ratingOutOfFive(starValue),
                                constraints: const BoxConstraints(
                                  minWidth: 44,
                                  minHeight: 44,
                                ),
                                padding: const EdgeInsets.all(4),
                                style: IconButton.styleFrom(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: provider.isSubmitting
                                    ? null
                                    : () => setState(() {
                                          _selectedRating = starValue;
                                        }),
                                icon: Icon(
                                  isSelected
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  size: 34,
                                  color: isSelected
                                      ? ShamsColors.solarYellow
                                      : ext?.textHint ?? ShamsColors.textHint,
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_selectedRating/5 — ${_ratingLabel(_selectedRating, l10n)}',
                          style: GoogleFonts.tajawal(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _commentController,
                    enabled: !provider.isSubmitting,
                    maxLines: 4,
                    minLines: 3,
                    maxLength: 500,
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.reviewCommentHint,
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: ext?.inputFill ??
                          colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: ext?.borderLight ?? colorScheme.outline,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: ext?.borderLight ?? colorScheme.outline,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.pleaseWriteReviewComment;
                      }
                      return null;
                    },
                  ),
                  if (provider.errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.localizeErrorMessage(provider.errorMessage!),
                      style: GoogleFonts.tajawal(
                        fontSize: 13,
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: CustomOutlinedButton(
                            title: l10n.cancel,
                            onPressed: provider.isSubmitting
                                ? null
                                : () {
                                    provider.clearError();
                                    Navigator.of(context).pop(false);
                                  },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomSolidButton(
                            title: _isEditing
                                ? l10n.saveEdits
                                : l10n.publishReview,
                            isLoading: provider.isSubmitting,
                            onPressed: provider.isSubmitting ? null : _submit,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
