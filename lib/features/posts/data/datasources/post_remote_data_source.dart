import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shams_mobile_app/core/data/datasources/file_storage_data_source.dart';
import 'package:shams_mobile_app/core/error/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class PostRemoteDataSource {
  Future<Map<String, dynamic>> createPost({
    required String workshopId,
    required String textDetails,
    List<String> imagePaths = const [],
    bool isHighlighted = false,
  });

  Future<List<Map<String, dynamic>>> fetchFeed({
    required String currentUserId,
    int limit = 20,
    int offset = 0,
  });

  Future<List<Map<String, dynamic>>> fetchWorkshopPosts({
    required String workshopId,
    int limit = 20,
    int offset = 0,
  });

  Future<void> updatePost({
    required String postId,
    String? textDetails,
    bool? isHighlighted,
  });

  Future<void> deletePost(String postId);

  Future<bool> toggleLike(String postId);

  Future<Set<String>> fetchLikedPostIds(List<String> postIds);

  Future<List<Map<String, dynamic>>> fetchCommentsForPosts(
    List<String> postIds,
  );

  Future<List<Map<String, dynamic>>> fetchComments(String postId);

  Future<Map<String, dynamic>> addComment({
    required String postId,
    required String text,
  });

  Future<void> deleteComment(String commentId);

  Future<bool> toggleCommentLike(String commentId);

  Future<void> savePost(String postId);

  Future<void> unsavePost(String postId);

  Future<void> hidePost(String postId);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  PostRemoteDataSourceImpl(
    this._db,
    this._storage, {
    DateTime Function()? clock,
    bool useDbNotificationTriggers = false,
  })  : _clock = clock ?? DateTime.now,
        _useDbNotificationTriggers = useDbNotificationTriggers;

  static const _postsBucket = 'posts';

  final SupabaseClient _db;
  final FileStorageDataSource _storage;
  final DateTime Function() _clock;
  final bool _useDbNotificationTriggers;

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
      debugPrint(
        'Post PostgrestException [${e.code}]: ${e.message} '
        '(details: ${e.details}, hint: ${e.hint})',
      );
      throw ServerException(e.message);
    } on AuthException catch (e) {
      throw AppAuthException(e.message);
    }
  }

  @override
  Future<Map<String, dynamic>> createPost({
    required String workshopId,
    required String textDetails,
    List<String> imagePaths = const [],
    bool isHighlighted = false,
  }) {
    return _guardDb(() async {
      final userId = _requireUserId();
      final timestamp = _clock().millisecondsSinceEpoch;

      final imageUrls = <String>[];
      for (int i = 0; i < imagePaths.length; i++) {
        final url = await _storage.uploadFile(
          bucket: _postsBucket,
          path: '$userId/${timestamp}_$i.jpg',
          localFilePath: imagePaths[i],
        );
        imageUrls.add(url);
      }

      return await _db.from('posts').insert({
        'workshop_id': workshopId,
        'author_id': userId,
        'text_details': textDetails,
        'images': imageUrls,
        'is_highlighted': isHighlighted,
      }).select('''
      *,
      profiles!posts_author_id_fkey(id, name, username, profile_image_url, is_verified)
    ''').single();
    });
  }

  @override
  Future<List<Map<String, dynamic>>> fetchFeed({
    required String currentUserId,
    int limit = 20,
    int offset = 0,
  }) {
    return _guardDb(() async {
      final hiddenRows = await _db
          .from('hidden_posts')
          .select('post_id')
          .eq('user_id', currentUserId);
      final hiddenIds = hiddenRows
          .map((r) => r['post_id'] as String?)
          .whereType<String>()
          .toList();

      var query = _db.from('posts').select('''
          *,
          profiles!posts_author_id_fkey(id, name, username, profile_image_url, is_verified),
          workshops!posts_workshop_id_fkey(id, name, handle, logo_url)
        ''');

      if (hiddenIds.isNotEmpty) {
        query = query.not('id', 'in', hiddenIds);
      }

      return await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
    });
  }

  Future<void> _incrementPostsViews(List<String> postIds) async {
    if (postIds.isEmpty) return;
    try {
      await _db.rpc(
        'increment_post_views',
        params: {'post_ids': postIds},
      );
      return;
    } on PostgrestException catch (e) {
      // Fall back to legacy loop only until increment_post_views RPC is deployed.
      final isMissingRpc = e.code == 'PGRST202' || e.code == '42883';
      if (!isMissingRpc) {
        debugPrint('Error incrementing posts views via RPC: $e');
        return;
      }
    } catch (e) {
      debugPrint('Error incrementing posts views via RPC: $e');
      return;
    }

    try {
      for (final id in postIds) {
        final post = await _db
            .from('posts')
            .select('views_count')
            .eq('id', id)
            .maybeSingle();
        if (post != null) {
          final current = post['views_count'] as int? ?? 0;
          await _db
              .from('posts')
              .update({'views_count': current + 1})
              .eq('id', id);
        }
      }
    } catch (e) {
      debugPrint('Error incrementing posts views: $e');
    }
  }

  /// Exposes post view incrementation for targeted data source unit tests.
  @visibleForTesting
  Future<void> incrementPostsViewsForTest(List<String> postIds) =>
      _incrementPostsViews(postIds);

  @override
  Future<List<Map<String, dynamic>>> fetchWorkshopPosts({
    required String workshopId,
    int limit = 20,
    int offset = 0,
  }) {
    return _guardDb(() async {
      final posts = await _db
          .from('posts')
          .select('''
          *,
          profiles!posts_author_id_fkey(id, name, username, profile_image_url)
        ''')
          .eq('workshop_id', workshopId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final postIds = posts.map((p) => p['id'] as String).toList();
      unawaited(_incrementPostsViews(postIds));

      return posts;
    });
  }

  @override
  Future<void> updatePost({
    required String postId,
    String? textDetails,
    bool? isHighlighted,
  }) {
    return _guardDb(() async {
      final updates = <String, dynamic>{};
      if (textDetails != null) updates['text_details'] = textDetails;
      if (isHighlighted != null) updates['is_highlighted'] = isHighlighted;

      await _db.from('posts').update(updates).eq('id', postId);
    });
  }

  @override
  Future<void> deletePost(String postId) {
    return _guardDb(() => _db.from('posts').delete().eq('id', postId));
  }

  @override
  Future<bool> toggleLike(String postId) {
    return _guardDb(() async {
      final userId = _requireUserId();
      final existing = await _db
          .from('post_likes')
          .select('id')
          .eq('post_id', postId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        await _db.from('post_likes').delete().eq('id', existing['id']);
        return false;
      } else {
        await _db.from('post_likes').insert({
          'post_id': postId,
          'user_id': userId,
        });
        if (!_useDbNotificationTriggers) {
          unawaited(_createLikeNotification(postId, userId));
        }
        return true;
      }
    });
  }

  Future<void> _createLikeNotification(String postId, String likerId) async {
    try {
      final post = await _db
          .from('posts')
          .select('author_id, text_details')
          .eq('id', postId)
          .single();
      final authorId = post['author_id'] as String?;
      if (authorId == null || authorId == likerId) return;

      final likerProfile = await _db
          .from('profiles')
          .select('name')
          .eq('id', likerId)
          .maybeSingle();
      final likerName = likerProfile?['name'] ?? 'مستخدم شمس';

      final textSnippet = post['text_details'] as String? ?? '';
      final truncatedText = textSnippet.length > 30
          ? '${textSnippet.substring(0, 30)}...'
          : textSnippet;

      await _db.from('notifications').insert({
        'user_id': authorId,
        'title': 'إعجاب جديد',
        'message': 'قام $likerName بالإعجاب بمنشورك: "$truncatedText"',
        'type': 'like',
        'target_id': postId,
      });
    } catch (e) {
      debugPrint('Error creating like notification: $e');
    }
  }

  @override
  Future<Set<String>> fetchLikedPostIds(List<String> postIds) {
    return _guardDb(() async {
      if (postIds.isEmpty) return <String>{};
      final userId = _requireUserId();
      final rows = await _db
          .from('post_likes')
          .select('post_id')
          .eq('user_id', userId)
          .inFilter('post_id', postIds);
      return rows.map((r) => r['post_id'] as String).toSet();
    });
  }

  @override
  Future<List<Map<String, dynamic>>> fetchCommentsForPosts(
    List<String> postIds,
  ) {
    return _guardDb(() async {
      if (postIds.isEmpty) return const <Map<String, dynamic>>[];
      return await _db
          .from('comments')
          .select('''
          *,
          profiles!comments_user_id_fkey(id, name, username, profile_image_url)
        ''')
          .inFilter('post_id', postIds)
          .order('created_at', ascending: true);
    });
  }

  @override
  Future<List<Map<String, dynamic>>> fetchComments(String postId) {
    return fetchCommentsForPosts([postId]);
  }

  @override
  Future<Map<String, dynamic>> addComment({
    required String postId,
    required String text,
  }) {
    return _guardDb(() async {
      final userId = _requireUserId();
      return await _db.from('comments').insert({
        'post_id': postId,
        'user_id': userId,
        'text': text,
      }).select('''
      *,
      profiles!comments_user_id_fkey(id, name, username, profile_image_url)
    ''').single();
    });
  }

  @override
  Future<void> deleteComment(String commentId) {
    return _guardDb(
      () => _db.from('comments').delete().eq('id', commentId),
    );
  }

  @override
  Future<bool> toggleCommentLike(String commentId) {
    return _guardDb(() async {
      final userId = _requireUserId();
      final existing = await _db
          .from('comment_likes')
          .select('id')
          .eq('comment_id', commentId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        await _db.from('comment_likes').delete().eq('id', existing['id']);
        return false;
      } else {
        await _db.from('comment_likes').insert({
          'comment_id': commentId,
          'user_id': userId,
        });
        return true;
      }
    });
  }

  @override
  Future<void> savePost(String postId) {
    return _guardDb(() async {
      final userId = _requireUserId();
      await _db.from('saved_posts').insert({
        'post_id': postId,
        'user_id': userId,
      });
    });
  }

  @override
  Future<void> unsavePost(String postId) {
    return _guardDb(() async {
      final userId = _requireUserId();
      await _db
          .from('saved_posts')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', userId);
    });
  }

  @override
  Future<void> hidePost(String postId) {
    return _guardDb(() async {
      final userId = _requireUserId();
      await _db.from('hidden_posts').insert({
        'post_id': postId,
        'user_id': userId,
      });
    });
  }
}
