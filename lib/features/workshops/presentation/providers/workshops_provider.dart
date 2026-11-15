import 'package:flutter/foundation.dart';
import 'package:shams_mobile_app/core/presentation/resettable.dart';
import 'package:shams_mobile_app/core/presentation/view_status.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/posts/domain/entities/post.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/my_workshop.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/workshop.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/get_public_workshops_usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/toggle_follow_usecase.dart';

/// State manager for the public workshops directory and follow actions.
class WorkshopsProvider extends ChangeNotifier implements Resettable {
  static const int defaultPageSize = 20;

  WorkshopsProvider({
    required GetPublicWorkshopsUseCase getPublicWorkshops,
    required ToggleFollowUseCase toggleFollow,
    int pageSize = defaultPageSize,
  })  : _getPublicWorkshops = getPublicWorkshops,
        _toggleFollow = toggleFollow,
        _pageSize = pageSize;

  final GetPublicWorkshopsUseCase _getPublicWorkshops;
  final ToggleFollowUseCase _toggleFollow;
  final int _pageSize;

  final List<Workshop> _workshops = [];
  MyWorkshop? _syncedMyWorkshop;
  List<Post> _syncedMyPosts = const [];
  String? _syncedPendingLogoPath;
  String? _syncedPendingCoverPath;

  ViewStatus _status = ViewStatus.initial;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  int _nextOffset = 0;
  String? _errorMessage;

  List<Workshop> get workshops => List.unmodifiable(_workshops);
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

    final result = await _getPublicWorkshops(
      GetPublicWorkshopsParams(limit: _pageSize, offset: 0),
    );
    switch (result) {
      case Ok(:final data):
        _workshops
          ..clear()
          ..addAll(data);
        _nextOffset = data.length;
        _hasMore = data.length >= _pageSize;
        if (_syncedMyWorkshop != null) {
          _applySyncedWorkshopToList();
        }
        _status = ViewStatus.success;
      case Err(:final failure):
        _status = ViewStatus.failure;
        _errorMessage = failure.message;
    }
    notifyListeners();
  }

  /// Appends the next directory page when more workshops remain on the server.
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _status == ViewStatus.loading) return;

    _isLoadingMore = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getPublicWorkshops(
      GetPublicWorkshopsParams(limit: _pageSize, offset: _nextOffset),
    );
    switch (result) {
      case Ok(:final data):
        final existingIds = _workshops.map((w) => w.id).toSet();
        for (final workshop in data) {
          if (existingIds.add(workshop.id)) {
            _workshops.add(workshop);
          }
        }
        _nextOffset += data.length;
        _hasMore = data.length >= _pageSize;
        if (_syncedMyWorkshop != null) {
          _applySyncedWorkshopToList();
        }
        _isLoadingMore = false;
      case Err(:final failure):
        _isLoadingMore = false;
        _errorMessage = failure.message;
    }
    notifyListeners();
  }

  /// Returns the workshop with [id], or null if not found.
  Workshop? getWorkshopById(String id) {
    for (final workshop in _workshops) {
      if (workshop.id == id) return workshop;
    }
    return null;
  }

  /// Returns the workshop owned by [ownerId], or null if not found.
  Workshop? getWorkshopByOwnerId(String ownerId) {
    for (final workshop in _workshops) {
      if (workshop.ownerId == ownerId) return workshop;
    }
    return null;
  }

  /// Optimistically toggles follow state and reverts with [errorMessage] on failure.
  Future<bool> toggleFollow(String workshopId) async {
    final index = _workshops.indexWhere((w) => w.id == workshopId);
    if (index == -1) return false;

    final original = _workshops[index];
    final currentlyFollowing = original.isFollowing;
    _workshops[index] = original.copyWith(isFollowing: !currentlyFollowing);
    _errorMessage = null;
    notifyListeners();

    final result = await _toggleFollow(
      ToggleFollowParams(
        workshopId: workshopId,
        isCurrentlyFollowing: currentlyFollowing,
      ),
    );
    switch (result) {
      case Ok():
        return true;
      case Err(:final failure):
        final revertIndex = _workshops.indexWhere((w) => w.id == workshopId);
        if (revertIndex != -1) {
          _workshops[revertIndex] = original;
        }
        _errorMessage = failure.message;
        notifyListeners();
        return false;
    }
  }

  /// Patches or inserts the signed-in owner's workshop entry in the directory.
  void applyMyWorkshop(
    MyWorkshop? myWorkshop,
    List<Post> posts, {
    String? pendingLogoPath,
    String? pendingCoverPath,
  }) {
    _syncedMyWorkshop = myWorkshop;
    _syncedMyPosts = List.unmodifiable(posts);
    _syncedPendingLogoPath = pendingLogoPath;
    _syncedPendingCoverPath = pendingCoverPath;

    if (myWorkshop == null) return;
    _applySyncedWorkshopToList();
    notifyListeners();
  }

  /// Updates cached rating and review count for [workshopId] in the directory.
  void updateReviewSummary(
    String workshopId, {
    required double rating,
    required int reviewCount,
  }) {
    final index = _workshops.indexWhere((w) => w.id == workshopId);
    if (index == -1) return;
    final existing = _workshops[index];
    if (existing.rating == rating && existing.reviewCount == reviewCount) {
      return;
    }
    _workshops[index] = existing.copyWith(
      rating: rating,
      reviewCount: reviewCount,
    );
    if (_syncedMyWorkshop != null && _syncedMyWorkshop!.id == workshopId) {
      _syncedMyWorkshop = _syncedMyWorkshop!.copyWith(
        rating: rating,
        reviewCount: reviewCount,
      );
    }
    notifyListeners();
  }

  void _applySyncedWorkshopToList() {
    final myWorkshop = _syncedMyWorkshop;
    if (myWorkshop == null) return;

    final logoUrl = _syncedPendingLogoPath ?? myWorkshop.logoUrl;
    final coverUrl = _syncedPendingCoverPath ?? myWorkshop.coverUrl;
    final index = _workshops.indexWhere((w) => w.id == myWorkshop.id);

    if (index != -1) {
      final existing = _workshops[index];
      _workshops[index] = existing.copyWith(
        name: myWorkshop.name,
        handle: '@${myWorkshop.username}',
        city: myWorkshop.city,
        description: myWorkshop.description,
        logoUrl: logoUrl ?? existing.logoUrl,
        coverUrl: coverUrl ?? existing.coverUrl,
        galleryUrls: myWorkshop.galleryUrls,
        yearsOfExperience: myWorkshop.yearsOfExperience,
        posts: List<Post>.from(_syncedMyPosts),
      );
    } else {
      _workshops.insert(
        0,
        Workshop(
          id: myWorkshop.id,
          ownerId: myWorkshop.ownerId,
          name: myWorkshop.name,
          handle: '@${myWorkshop.username}',
          city: myWorkshop.city,
          rating: myWorkshop.rating,
          reviewCount: myWorkshop.reviewCount,
          description: myWorkshop.description,
          logoUrl: logoUrl,
          coverUrl: coverUrl,
          galleryUrls: myWorkshop.galleryUrls,
          yearsOfExperience: myWorkshop.yearsOfExperience,
          isFollowing: false,
          posts: List<Post>.from(_syncedMyPosts),
        ),
      );
    }
  }

  @override
  void reset() {
    _workshops.clear();
    _syncedMyWorkshop = null;
    _syncedMyPosts = const [];
    _syncedPendingLogoPath = null;
    _syncedPendingCoverPath = null;
    _status = ViewStatus.initial;
    _hasMore = true;
    _isLoadingMore = false;
    _nextOffset = 0;
    _errorMessage = null;
    notifyListeners();
  }
}
