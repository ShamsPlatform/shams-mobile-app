import 'package:shams_mobile_app/core/data/models/app_user_model.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/review.dart';

/// Maps Supabase review rows to domain [Review] entities.
class ReviewModel {
  const ReviewModel._();

  static Review fromJson(Map<String, dynamic> json) {
    final rawReviewer = json['profiles'] ?? json['reviewer'];
    final reviewerMap = rawReviewer is Map<String, dynamic>
        ? rawReviewer
        : const <String, dynamic>{};

    final rawCreatedAt = json['created_at'];
    final createdAt = rawCreatedAt is String && rawCreatedAt.isNotEmpty
        ? DateTime.parse(rawCreatedAt).toLocal()
        : DateTime.now();

    return Review(
      id: json['id'] as String? ?? '',
      reviewer: AppUserModel.fromJson(reviewerMap),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'] as String? ?? '',
      createdAt: createdAt,
    );
  }
}
