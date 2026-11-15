import 'package:shams_mobile_app/core/error/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for workshop reviews.
abstract interface class ReviewRemoteDataSource {
  Future<Map<String, dynamic>> addReview({
    required String workshopId,
    required double rating,
    required String comment,
  });

  Future<List<Map<String, dynamic>>> fetchWorkshopReviews(String workshopId);

  Future<void> updateReview({
    required String reviewId,
    double? rating,
    String? comment,
  });

  Future<void> deleteReview(String reviewId);
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  ReviewRemoteDataSourceImpl(this._db);

  final SupabaseClient _db;

  String _requireUserId() {
    final user = _db.auth.currentUser;
    if (user == null) {
      throw const AppAuthException('لا يوجد مستخدم مسجل دخول');
    }
    return user.id;
  }

  Future<T> _guardDb<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } on AuthException catch (e) {
      throw AppAuthException(e.message);
    }
  }

  @override
  Future<Map<String, dynamic>> addReview({
    required String workshopId,
    required double rating,
    required String comment,
  }) {
    return _guardDb(() async {
      final userId = _requireUserId();
      return await _db.from('reviews').insert({
        'workshop_id': workshopId,
        'reviewer_id': userId,
        'rating': rating,
        'comment': comment,
      }).select('''
      *,
      profiles!reviews_reviewer_id_fkey(id, name, profile_image_url)
    ''').single();
    });
  }

  @override
  Future<List<Map<String, dynamic>>> fetchWorkshopReviews(String workshopId) {
    return _guardDb(() async {
      return await _db
          .from('reviews')
          .select('''
          *,
          profiles!reviews_reviewer_id_fkey(id, name, profile_image_url)
        ''')
          .eq('workshop_id', workshopId)
          .order('created_at', ascending: false);
    });
  }

  @override
  Future<void> updateReview({
    required String reviewId,
    double? rating,
    String? comment,
  }) {
    return _guardDb(() async {
      final updates = <String, dynamic>{};
      if (rating != null) updates['rating'] = rating;
      if (comment != null) updates['comment'] = comment;
      if (updates.isEmpty) return;
      await _db.from('reviews').update(updates).eq('id', reviewId);
    });
  }

  @override
  Future<void> deleteReview(String reviewId) {
    return _guardDb(() async {
      await _db.from('reviews').delete().eq('id', reviewId);
    });
  }
}
