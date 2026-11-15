import 'package:shams_mobile_app/core/domain/entities/app_user.dart';

/// A single user review submitted for a workshop.
class Review {
  final String id;
  final AppUser reviewer;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.reviewer,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Review copyWith({
    String? id,
    AppUser? reviewer,
    double? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return Review(
      id: id ?? this.id,
      reviewer: reviewer ?? this.reviewer,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
