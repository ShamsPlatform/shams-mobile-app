import 'package:flutter/foundation.dart';
import 'package:shams_mobile_app/core/presentation/view_status.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/review.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/add_review_usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/delete_review_usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/get_workshop_reviews_usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/update_review_usecase.dart';

/// State manager for reading, creating, editing, and deleting workshop reviews.
class WorkshopReviewsProvider extends ChangeNotifier {
  WorkshopReviewsProvider({
    required GetWorkshopReviewsUseCase getWorkshopReviews,
    required AddReviewUseCase addReview,
    required UpdateReviewUseCase updateReview,
    required DeleteReviewUseCase deleteReview,
  })  : _getWorkshopReviews = getWorkshopReviews,
        _addReview = addReview,
        _updateReview = updateReview,
        _deleteReview = deleteReview;

  final GetWorkshopReviewsUseCase _getWorkshopReviews;
  final AddReviewUseCase _addReview;
  final UpdateReviewUseCase _updateReview;
  final DeleteReviewUseCase _deleteReview;

  final List<Review> _reviews = [];
  ViewStatus _status = ViewStatus.initial;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _loadedWorkshopId;

  List<Review> get reviews => List.unmodifiable(_reviews);
  ViewStatus get status => _status;
  bool get isLoading => _status == ViewStatus.loading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get loadedWorkshopId => _loadedWorkshopId;
  int get reviewCount => _reviews.length;

  double get averageRating {
    if (_reviews.isEmpty) return 0.0;
    final total = _reviews.fold<double>(0.0, (sum, r) => sum + r.rating);
    return double.parse((total / _reviews.length).toStringAsFixed(1));
  }

  /// Returns the review authored by [userId], or `null` if none exists.
  Review? findReviewByUserId(String? userId) {
    if (userId == null || userId.isEmpty) return null;
    for (final review in _reviews) {
      if (review.reviewer.id == userId) return review;
    }
    return null;
  }

  Future<void> load(
    String workshopId, {
    List<Review> initialReviews = const [],
  }) async {
    _loadedWorkshopId = workshopId;
    if (_reviews.isEmpty && initialReviews.isNotEmpty) {
      _reviews
        ..clear()
        ..addAll(initialReviews);
    }
    _status = ViewStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _getWorkshopReviews(workshopId);
    switch (result) {
      case Ok(:final data):
        _reviews
          ..clear()
          ..addAll(data);
        _status = ViewStatus.success;
      case Err(:final failure):
        _status = ViewStatus.failure;
        _errorMessage = failure.message;
    }
    notifyListeners();
  }

  Future<bool> addReview({
    required String workshopId,
    required double rating,
    required String comment,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _addReview(
      AddReviewParams(
        workshopId: workshopId,
        rating: rating,
        comment: comment,
      ),
    );
    _isSubmitting = false;
    switch (result) {
      case Ok(:final data):
        _reviews.insert(0, data);
        if (_status == ViewStatus.initial || _status == ViewStatus.failure) {
          _status = ViewStatus.success;
        }
        notifyListeners();
        return true;
      case Err(:final failure):
        _errorMessage = failure.message;
        notifyListeners();
        return false;
    }
  }

  Future<bool> updateReview({
    required String reviewId,
    required double rating,
    required String comment,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final trimmedComment = comment.trim();
    final result = await _updateReview(
      UpdateReviewParams(
        reviewId: reviewId,
        rating: rating,
        comment: trimmedComment,
      ),
    );
    _isSubmitting = false;
    switch (result) {
      case Ok():
        final index = _reviews.indexWhere((r) => r.id == reviewId);
        if (index != -1) {
          final existing = _reviews[index];
          _reviews[index] = Review(
            id: existing.id,
            reviewer: existing.reviewer,
            rating: rating,
            comment: trimmedComment,
            createdAt: existing.createdAt,
          );
        }
        notifyListeners();
        return true;
      case Err(:final failure):
        _errorMessage = failure.message;
        notifyListeners();
        return false;
    }
  }

  Future<bool> deleteReview(String reviewId) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _deleteReview(reviewId);
    _isSubmitting = false;
    switch (result) {
      case Ok():
        _reviews.removeWhere((r) => r.id == reviewId);
        notifyListeners();
        return true;
      case Err(:final failure):
        _errorMessage = failure.message;
        notifyListeners();
        return false;
    }
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }
}
