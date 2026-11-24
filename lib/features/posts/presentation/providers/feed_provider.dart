import 'package:flutter/foundation.dart';
import 'package:shams_mobile_app/core/presentation/resettable.dart';
import 'package:shams_mobile_app/core/presentation/view_status.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/posts/domain/entities/comment.dart';
import 'package:shams_mobile_app/features/posts/domain/entities/post.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/add_comment_usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/delete_comment_usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/get_feed_usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/hide_post_usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/toggle_comment_like_usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/toggle_post_like_usecase.dart';

/// State manager for the home posts feed, likes, comments, and post hiding.
class FeedProvider extends ChangeNotifier implements Resettable {
  static const int defaultPageSize = 20;

  FeedProvider({
    required GetFeedUseCase getFeed,
    required TogglePostLikeUseCase toggleLike,
    required AddCommentUseCase addComment,
    required DeleteCommentUseCase deleteComment,
    required ToggleCommentLikeUseCase toggleCommentLike,
    required HidePostUseCase hidePost,
    int pageSize = defaultPageSize,
  })  : _getFeed = getFeed,
        _toggleLike = toggleLike,
        _addComment = addComment,
        _deleteComment = deleteComment,
        _toggleCommentLike = toggleCommentLike,
        _hidePost = hidePost,
        _pageSize = pageSize;

  final GetFeedUseCase _getFeed;
  final TogglePostLikeUseCase _toggleLike;
  final AddCommentUseCase _addComment;
  final DeleteCommentUseCase _deleteComment;
  final ToggleCommentLikeUseCase _toggleCommentLike;
  final HidePostUseCase _hidePost;
  final int _pageSize;

  final List<Post> _posts = [];
  ViewStatus _status = ViewStatus.initial;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  int _nextOffset = 0;
  String? _errorMessage;

  List<Post> get posts => List.unmodifiable(_posts);
  ViewStatus get status => _status;
  bool get isLoading => _status == ViewStatus.loading;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _status = ViewStatus.loading;
    _errorMessage = null;
    _hasMore = true;
    _isLoadingMore = false;
    _nextOffset = 0;
    notifyListeners();

    final result = await _getFeed(GetFeedParams(limit: _pageSize, offset: 0));
    switch (result) {
      case Ok(:final data):
        _posts.clear();
        final seenIds = <String>{};
        for (final post in data) {
          if (seenIds.add(post.id)) {
            _posts.add(post);
          }
        }
        _nextOffset = data.length;
        _hasMore = data.length >= _pageSize;
        _status = ViewStatus.success;
      case Err(:final failure):
        _status = ViewStatus.failure;
        _errorMessage = failure.message;
    }
    notifyListeners();
  }

  /// Appends the next page of posts when more items remain on the server.
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _status == ViewStatus.loading) return;

    _isLoadingMore = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getFeed(
      GetFeedParams(limit: _pageSize, offset: _nextOffset),
    );
    switch (result) {
      case Ok(:final data):
        final existingIds = _posts.map((p) => p.id).toSet();
        for (final post in data) {
          if (existingIds.add(post.id)) {
            _posts.add(post);
          }
        }
        _nextOffset += data.length;
        _hasMore = data.length >= _pageSize;
        _isLoadingMore = false;
      case Err(:final failure):
        _isLoadingMore = false;
        _errorMessage = failure.message;
    }
    notifyListeners();
  }

  /// Returns the post with [id], or null if not found.
  Post? getPostById(String id) {
    for (final post in _posts) {
      if (post.id == id) return post;
    }
    return null;
  }

  Future<void> toggleLike(String postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final original = _posts[index];
    final newIsLiked = !original.isLiked;
    final newLikesCount =
        newIsLiked ? original.likesCount + 1 : original.likesCount - 1;

    _posts[index] = original.copyWith(
      isLiked: newIsLiked,
      likesCount: newLikesCount,
    );
    _errorMessage = null;
    notifyListeners();

    final result = await _toggleLike(postId);
    if (result case Err(:final failure)) {
      final currentIndex = _posts.indexWhere((p) => p.id == postId);
      if (currentIndex != -1) {
        _posts[currentIndex] = original;
      }
      _errorMessage = failure.message;
      notifyListeners();
    }
  }

  Future<void> addComment(String postId, String text) async {
    final result = await _addComment(AddCommentParams(postId: postId, text: text));
    switch (result) {
      case Ok(:final data):
        final index = _posts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          final post = _posts[index];
          _posts[index] = post.copyWith(
            comments: [...post.comments, data],
          );
        }
        _errorMessage = null;
        notifyListeners();
      case Err(:final failure):
        _errorMessage = failure.message;
        notifyListeners();
    }
  }

  Future<void> deleteComment(String postId, String commentId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final original = _posts[index];
    final updated = original.comments.where((c) => c.id != commentId).toList();
    _posts[index] = original.copyWith(comments: updated);
    _errorMessage = null;
    notifyListeners();

    final result = await _deleteComment(commentId);
    if (result case Err(:final failure)) {
      final currentIndex = _posts.indexWhere((p) => p.id == postId);
      if (currentIndex != -1) {
        _posts[currentIndex] = original;
      }
      _errorMessage = failure.message;
      notifyListeners();
    }
  }

  /// Toggles the like state for a single comment inside [postId].
  Future<void> toggleCommentLike(String postId, String commentId) async {
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex == -1) return;
    final originalPost = _posts[postIndex];

    final commentIndex =
        originalPost.comments.indexWhere((c) => c.id == commentId);
    if (commentIndex == -1) return;

    final originalComment = originalPost.comments[commentIndex];
    final newIsLiked = !originalComment.isLiked;
    final newLikesCount = newIsLiked
        ? originalComment.likesCount + 1
        : originalComment.likesCount - 1;

    final updatedComments = List<Comment>.from(originalPost.comments);
    updatedComments[commentIndex] = originalComment.copyWith(
      isLiked: newIsLiked,
      likesCount: newLikesCount,
    );
    _posts[postIndex] = originalPost.copyWith(comments: updatedComments);
    _errorMessage = null;
    notifyListeners();

    final result = await _toggleCommentLike(commentId);
    if (result case Err(:final failure)) {
      final currentPostIndex = _posts.indexWhere((p) => p.id == postId);
      if (currentPostIndex != -1) {
        _posts[currentPostIndex] = originalPost;
      }
      _errorMessage = failure.message;
      notifyListeners();
    }
  }

  /// Inserts [post] at the top of the feed (newest-first), or replaces the
  /// existing entry in place if a post with the same [Post.id] is already present.
  void addPost(Post post) {
    final existingIndex = _posts.indexWhere((p) => p.id == post.id);
    if (existingIndex != -1) {
      _posts[existingIndex] = post;
    } else {
      _posts.insert(0, post);
      _nextOffset++;
    }
    notifyListeners();
  }

  /// Replaces the post with the same [id] with [updatedPost].
  void updatePost(Post updatedPost) {
    final index = _posts.indexWhere((p) => p.id == updatedPost.id);
    if (index != -1) {
      _posts[index] = updatedPost;
      notifyListeners();
    }
  }

  /// Permanently removes [postId] from the feed.
  void deletePost(String postId) {
    final before = _posts.length;
    _posts.removeWhere((p) => p.id == postId);
    if (_posts.length < before && _nextOffset > 0) {
      _nextOffset--;
    }
    notifyListeners();
  }

  /// Hides [postId] from the local feed and persists the hidden record.
  Future<void> hidePost(String postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final removed = _posts.removeAt(index);
    if (_nextOffset > 0) _nextOffset--;
    _errorMessage = null;
    notifyListeners();

    final result = await _hidePost(postId);
    if (result case Err(:final failure)) {
      final restoreIndex = index <= _posts.length ? index : _posts.length;
      _posts.insert(restoreIndex, removed);
      _nextOffset++;
      _errorMessage = failure.message;
      notifyListeners();
    }
  }

  @override
  void reset() {
    _posts.clear();
    _status = ViewStatus.initial;
    _hasMore = true;
    _isLoadingMore = false;
    _nextOffset = 0;
    _errorMessage = null;
    notifyListeners();
  }
}
