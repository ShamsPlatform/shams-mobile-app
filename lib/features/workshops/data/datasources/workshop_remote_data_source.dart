import 'package:shams_mobile_app/core/data/datasources/file_storage_data_source.dart';
import 'package:shams_mobile_app/core/error/exceptions.dart';
import 'package:shams_mobile_app/features/workshops/domain/repositories/workshop_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class WorkshopRemoteDataSource {
  Future<Map<String, dynamic>> createWorkshop(CreateWorkshopParams params);

  Future<List<Map<String, dynamic>>> fetchPublicWorkshops({
    String? cityFilter,
    int limit = 20,
    int offset = 0,
  });

  Future<Set<String>> fetchFollowedWorkshopIds(List<String> workshopIds);

  Future<bool> isFollowing(String workshopId);

  Future<Map<String, dynamic>?> fetchMyWorkshop(String userId);

  Future<int> fetchFollowersCount(String workshopId);

  Future<void> updateWorkshop(UpdateWorkshopParams params);

  Future<String> uploadWorkshopImage({
    required String storagePath,
    required String localFilePath,
  });

  Future<void> followWorkshop(String workshopId);

  Future<void> unfollowWorkshop(String workshopId);

  // Not used by UI yet.
  Future<Map<String, dynamic>?> fetchWorkshopById(String workshopId);

  // Not used by UI yet.
  Future<void> deleteWorkshop(String workshopId);
}

class WorkshopRemoteDataSourceImpl implements WorkshopRemoteDataSource {
  WorkshopRemoteDataSourceImpl(this._db, this._storage);

  static const _workshopsBucket = 'workshops';

  final SupabaseClient _db;
  final FileStorageDataSource _storage;

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
  Future<Map<String, dynamic>> createWorkshop(CreateWorkshopParams params) {
    return _guardDb(() async {
      final userId = _requireUserId();

      String? logoUrl;
      String? coverUrl;
      final imageUrls = <String>[];

      if (params.logoPath != null) {
        logoUrl = await _storage.uploadFile(
          bucket: _workshopsBucket,
          path: '$userId/logo.jpg',
          localFilePath: params.logoPath!,
        );
      }
      if (params.coverPath != null) {
        coverUrl = await _storage.uploadFile(
          bucket: _workshopsBucket,
          path: '$userId/cover.jpg',
          localFilePath: params.coverPath!,
        );
      }
      for (int i = 0; i < params.galleryPaths.length; i++) {
        final url = await _storage.uploadFile(
          bucket: _workshopsBucket,
          path: '$userId/gallery_$i.jpg',
          localFilePath: params.galleryPaths[i],
        );
        imageUrls.add(url);
      }

      final data = await _db.from('workshops').insert({
        'owner_id': userId,
        'name': params.name,
        'city': params.city,
        'address': params.address,
        'description': params.description,
        'handle': params.handle,
        'logo_url': logoUrl,
        'cover_url': coverUrl,
        'images': imageUrls,
        'services': params.services,
        'years_of_experience': params.yearsOfExperience,
      }).select().single();

      // Mark user as workshop owner
      await _db
          .from('profiles')
          .update({'has_workshop': true}).eq('id', userId);

      return data;
    });
  }

  @override
  Future<List<Map<String, dynamic>>> fetchPublicWorkshops({
    String? cityFilter,
    int limit = 20,
    int offset = 0,
  }) {
    return _guardDb(() async {
      var query = _db.from('workshops').select(
            '*, profiles!workshops_owner_id_fkey(name, username, profile_image_url)',
          );

      if (cityFilter != null && cityFilter.isNotEmpty) {
        query = query.eq('city', cityFilter);
      }

      return await query
          .order('rating', ascending: false)
          .range(offset, offset + limit - 1);
    });
  }

  @override
  Future<Set<String>> fetchFollowedWorkshopIds(List<String> workshopIds) {
    return _guardDb(() async {
      if (workshopIds.isEmpty) return <String>{};
      final user = _db.auth.currentUser;
      if (user == null) return <String>{};
      final rows = await _db
          .from('follows')
          .select('workshop_id')
          .eq('follower_id', user.id)
          .inFilter('workshop_id', workshopIds);
      return rows
          .map((r) => r['workshop_id'] as String?)
          .whereType<String>()
          .toSet();
    });
  }

  @override
  Future<bool> isFollowing(String workshopId) async {
    final followedIds = await fetchFollowedWorkshopIds([workshopId]);
    return followedIds.contains(workshopId);
  }

  @override
  Future<Map<String, dynamic>?> fetchMyWorkshop(String userId) {
    return _guardDb(() async {
      return await _db
          .from('workshops')
          .select()
          .eq('owner_id', userId)
          .maybeSingle();
    });
  }

  @override
  Future<int> fetchFollowersCount(String workshopId) {
    return _guardDb(() async {
      final rows = await _db
          .from('follows')
          .select('id')
          .eq('workshop_id', workshopId);
      return rows.length;
    });
  }

  @override
  Future<void> updateWorkshop(UpdateWorkshopParams params) {
    return _guardDb(() async {
      final updates = <String, dynamic>{};
      if (params.name != null) updates['name'] = params.name;
      if (params.handle != null) updates['handle'] = params.handle;
      if (params.city != null) updates['city'] = params.city;
      if (params.description != null) {
        updates['description'] = params.description;
      }
      if (params.yearsOfExperience != null) {
        updates['years_of_experience'] = params.yearsOfExperience;
      }
      if (params.logoUrl != null) updates['logo_url'] = params.logoUrl;
      if (params.coverUrl != null) updates['cover_url'] = params.coverUrl;
      if (params.galleryUrls != null) updates['images'] = params.galleryUrls;

      if (updates.isEmpty) return;

      await _db
          .from('workshops')
          .update(updates)
          .eq('id', params.workshopId);
    });
  }

  @override
  Future<String> uploadWorkshopImage({
    required String storagePath,
    required String localFilePath,
  }) {
    return _storage.uploadFile(
      bucket: _workshopsBucket,
      path: storagePath,
      localFilePath: localFilePath,
    );
  }

  @override
  Future<void> followWorkshop(String workshopId) {
    return _guardDb(() async {
      final userId = _requireUserId();
      await _db.from('follows').insert({
        'follower_id': userId,
        'workshop_id': workshopId,
      });
    });
  }

  @override
  Future<void> unfollowWorkshop(String workshopId) {
    return _guardDb(() async {
      final userId = _requireUserId();
      await _db
          .from('follows')
          .delete()
          .eq('follower_id', userId)
          .eq('workshop_id', workshopId);
    });
  }

  @override
  Future<Map<String, dynamic>?> fetchWorkshopById(String workshopId) {
    return _guardDb(() async {
      return await _db
          .from('workshops')
          .select('''
          *,
          profiles!workshops_owner_id_fkey(name, username, profile_image_url),
          posts(*, profiles!posts_author_id_fkey(name, username, profile_image_url)),
          reviews(*, profiles!reviews_reviewer_id_fkey(name, username, profile_image_url))
        ''')
          .eq('id', workshopId)
          .maybeSingle();
    });
  }

  @override
  Future<void> deleteWorkshop(String workshopId) {
    return _guardDb(() async {
      await _db.from('workshops').delete().eq('id', workshopId);
    });
  }
}
