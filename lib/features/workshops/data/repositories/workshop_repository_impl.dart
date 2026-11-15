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
      final workshops = <Workshop>[];
      for (final row in rows) {
        final id = row['id'] as String? ?? '';
        final following = id.isNotEmpty ? await _remote.isFollowing(id) : false;
        workshops.add(WorkshopModel.fromJson(row, isFollowing: following));
      }
      return workshops;
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

      return MyWorkshopModel.fromJson(
        row,
        followersCount: followersCount,
        fallbackUsername: fallbackUsername,
      );
    });
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
