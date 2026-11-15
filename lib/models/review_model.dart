import 'package:shams_mobile_app/core/data/models/app_user_model.dart';
import 'package:shams_mobile_app/core/domain/entities/app_user.dart';

/// ReviewModel — نموذج بيانات التقييم
///
/// Represents a single user review for a workshop.
/// Managed as part of [PublicWorkshopModel.reviews].
class ReviewModel {
  /// Unique review identifier
  final String id;

  /// The user who submitted the review
  final AppUser reviewer;

  /// Rating from 1.0 to 5.0
  final double rating;

  /// Written review comment
  final String comment;

  /// When the review was posted
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.reviewer,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  ReviewModel copyWith({
    String? id,
    AppUser? reviewer,
    double? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      reviewer: reviewer ?? this.reviewer,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] ?? '',
      reviewer: AppUserModel.fromJson(map['reviewer'] ?? {}),
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      comment: map['comment'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  factory ReviewModel.fromSupabase(Map<String, dynamic> map) {
    final reviewerMap = map['profiles'] ?? {};
    return ReviewModel(
      id: map['id'] ?? '',
      reviewer: AppUserModel.fromJson(reviewerMap),
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      comment: map['comment'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }
}
