import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
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
  return showModalBottomSheet<bool>(
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

  String _ratingLabel(int rating) {
    return switch (rating) {
      1 => 'ضعيف',
      2 => 'مقبول',
      3 => 'جيد',
      4 => 'جيد جداً',
      _ => 'ممتاز',
    };
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

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
            _isEditing ? 'تم تحديث تقييمك بنجاح' : 'تم نشر تقييمك بنجاح',
            style: GoogleFonts.tajawal(),
          ),
          backgroundColor: ShamsColors.verifiedGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<ShamsExtendedColors>();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Consumer<WorkshopReviewsProvider>(
        builder: (context, provider, _) {
          return Container(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
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
                      _isEditing ? 'تعديل تقييمك' : 'أضف تقييمك للورشة',
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
                              return IconButton(
                                tooltip: '$starValue من 5',
                                onPressed: provider.isSubmitting
                                    ? null
                                    : () => setState(() {
                                          _selectedRating = starValue;
                                        }),
                                icon: Icon(
                                  isSelected
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  size: 36,
                                  color: isSelected
                                      ? ShamsColors.solarYellow
                                      : ext?.textHint ?? ShamsColors.textHint,
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_selectedRating/5 — ${_ratingLabel(_selectedRating)}',
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
                        labelText: 'اكتب تعليقك عن الخدمة وجودة التنفيذ',
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
                          return 'يرجى كتابة تعليق عن تجربتك مع الورشة';
                        }
                        return null;
                      },
                    ),
                    if (provider.errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        provider.errorMessage!,
                        style: GoogleFonts.tajawal(
                          fontSize: 13,
                          color: colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: FilledButton(
                              onPressed:
                                  provider.isSubmitting ? null : _submit,
                              style: FilledButton.styleFrom(
                                backgroundColor: ShamsColors.primaryBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: provider.isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      _isEditing
                                          ? 'حفظ التعديلات'
                                          : 'نشر التقييم',
                                      style: GoogleFonts.tajawal(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: provider.isSubmitting
                              ? null
                              : () {
                                  provider.clearError();
                                  Navigator.of(context).pop(false);
                                },
                          child: Text(
                            'إلغاء',
                            style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
