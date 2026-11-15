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
  WorkshopsProvider({
    required GetPublicWorkshopsUseCase getPublicWorkshops,
    required ToggleFollowUseCase toggleFollow,
  })  : _getPublicWorkshops = getPublicWorkshops,
        _toggleFollow = toggleFollow;

  final GetPublicWorkshopsUseCase _getPublicWorkshops;
  final ToggleFollowUseCase _toggleFollow;

  final List<Workshop> _workshops = [];
  MyWorkshop? _syncedMyWorkshop;
  List<Post> _syncedMyPosts = const [];
  String? _syncedPendingLogoPath;
  String? _syncedPendingCoverPath;

  ViewStatus _status = ViewStatus.initial;
  String? _errorMessage;

  List<Workshop> get workshops => List.unmodifiable(_workshops);
  ViewStatus get status => _status;
  bool get isLoading => _status == ViewStatus.loading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _status = ViewStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _getPublicWorkshops(const GetPublicWorkshopsParams());
    switch (result) {
      case Ok(:final data):
        _workshops
          ..clear()
          ..addAll(data);
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
    _errorMessage = null;
    notifyListeners();
  }
}
