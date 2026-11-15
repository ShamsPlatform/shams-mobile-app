import 'package:flutter/foundation.dart';
import 'package:shams_mobile_app/core/error/error_mapper.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/workshops/data/datasources/workshop_remote_data_source.dart';
import 'package:shams_mobile_app/features/workshops/data/models/my_workshop_model.dart';
import 'package:shams_mobile_app/features/workshops/data/models/review_model.dart';
import 'package:shams_mobile_app/features/workshops/data/models/workshop_model.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/my_workshop.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/review.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/workshop.dart';
import 'package:shams_mobile_app/features/workshops/domain/repositories/workshop_repository.dart';

class WorkshopRepositoryImpl implements WorkshopRepository {
  WorkshopRepositoryImpl(this._remote);

  final WorkshopRemoteDataSource _remote;

  @override
  Future<Result<List<Workshop>>> getPublicWorkshops({
    String? cityFilter,
    int limit = 20,
    int offset = 0,
  }) {
    return guard(() async {
      final rows = await _remote.fetchPublicWorkshops(
        cityFilter: cityFilter,
        limit: limit,
        offset: offset,
      );
      if (rows.isEmpty) return const <Workshop>[];

      final workshopIds = rows
          .map((r) => r['id'] as String?)
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toList();
      final followedIds = workshopIds.isNotEmpty
          ? await _remote.fetchFollowedWorkshopIds(workshopIds)
          : <String>{};
      final reviewSummaries = await _fetchReviewSummaries(workshopIds);

      return rows.map((row) {
        final id = row['id'] as String? ?? '';
        final workshop = WorkshopModel.fromJson(
          row,
          isFollowing: followedIds.contains(id),
        );
        if (reviewSummaries == null) return workshop;
        final summary = reviewSummaries[id];
        return workshop.copyWith(
          rating: summary?.average ?? 0.0,
          reviewCount: summary?.count ?? 0,
        );
      }).toList();
    });
  }

  @override
  Future<Result<MyWorkshop?>> getMyWorkshop({
    required String userId,
    String fallbackUsername = '',
  }) {
    return guard(() async {
      final row = await _remote.fetchMyWorkshop(userId);
      if (row == null) return null;

      final workshopId = row['id'] as String? ?? '';
      var followersCount = 0;
      if (workshopId.isNotEmpty) {
        try {
          followersCount = await _remote.fetchFollowersCount(workshopId);
        } catch (e) {
          debugPrint('Error fetching followers count: $e');
        }
      }
      final reviewSummaries = workshopId.isNotEmpty
          ? await _fetchReviewSummaries([workshopId])
          : null;

      final myWorkshop = MyWorkshopModel.fromJson(
        row,
        followersCount: followersCount,
        fallbackUsername: fallbackUsername,
      );
      if (reviewSummaries == null) return myWorkshop;
      final summary = reviewSummaries[workshopId];
      return myWorkshop.copyWith(
        rating: summary?.average ?? 0.0,
        reviewCount: summary?.count ?? 0,
      );
    });
  }

  Future<Map<String, ({double average, int count})>?> _fetchReviewSummaries(
    List<String> workshopIds,
  ) async {
    if (workshopIds.isEmpty) return const {};
    try {
      final rows = await _remote.fetchReviewRatingsForWorkshops(workshopIds);
      final totals = <String, ({double sum, int count})>{};
      for (final row in rows) {
        final workshopId = row['workshop_id'] as String?;
        final rating = (row['rating'] as num?)?.toDouble();
        if (workshopId == null || workshopId.isEmpty || rating == null) {
          continue;
        }
        final current = totals[workshopId];
        totals[workshopId] = (
          sum: (current?.sum ?? 0.0) + rating,
          count: (current?.count ?? 0) + 1,
        );
      }
      return totals.map((id, agg) {
        final avg = double.parse((agg.sum / agg.count).toStringAsFixed(1));
        return MapEntry(id, (average: avg, count: agg.count));
      });
    } catch (e) {
      debugPrint('Error fetching review summaries: $e');
      return null;
    }
  }

  @override
  Future<Result<MyWorkshop>> createWorkshop(CreateWorkshopParams params) {
    return guard(() async {
      final row = await _remote.createWorkshop(params);
      return MyWorkshopModel.fromJson(
        row,
        fallbackUsername: params.handle.replaceAll('@', ''),
      );
    });
  }

  @override
  Future<Result<void>> updateWorkshop(UpdateWorkshopParams params) {
    return guard(() => _remote.updateWorkshop(params));
  }

  @override
  Future<Result<String>> uploadWorkshopImage({
    required String storagePath,
    required String localFilePath,
  }) {
    return guard(
      () => _remote.uploadWorkshopImage(
        storagePath: storagePath,
        localFilePath: localFilePath,
      ),
    );
  }

  @override
  Future<Result<void>> followWorkshop(String workshopId) {
    return guard(() => _remote.followWorkshop(workshopId));
  }

  @override
  Future<Result<void>> unfollowWorkshop(String workshopId) {
    return guard(() => _remote.unfollowWorkshop(workshopId));
  }

  // Not used by UI yet.
  @override
  Future<Result<Workshop?>> getWorkshopById(String workshopId) {
    return guard(() async {
      final row = await _remote.fetchWorkshopById(workshopId);
      if (row == null) return null;

      final rawReviews = row['reviews'];
      final reviews = rawReviews is List
          ? rawReviews
              .whereType<Map<String, dynamic>>()
              .map(ReviewModel.fromJson)
              .toList()
          : const <Review>[];
      final following = await _remote.isFollowing(workshopId);
      return WorkshopModel.fromJson(
        row,
        isFollowing: following,
        reviews: reviews,
      );
    });
  }

  // Not used by UI yet.
  @override
  Future<Result<void>> deleteWorkshop(String workshopId) {
    return guard(() => _remote.deleteWorkshop(workshopId));
  }
}
