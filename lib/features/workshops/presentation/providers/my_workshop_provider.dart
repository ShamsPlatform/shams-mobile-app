import 'package:flutter/foundation.dart';
import 'package:shams_mobile_app/core/presentation/resettable.dart';
import 'package:shams_mobile_app/core/presentation/view_status.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/posts/domain/entities/post.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/delete_post_usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/get_workshop_posts_usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/entities/my_workshop.dart';
import 'package:shams_mobile_app/features/workshops/domain/repositories/workshop_repository.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/create_workshop_usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/get_my_workshop_usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/update_workshop_usecase.dart';
import 'package:shams_mobile_app/features/workshops/domain/usecases/upload_workshop_image_usecase.dart';

typedef SyncPublicWorkshopCallback = void Function(
  MyWorkshop? myWorkshop,
  List<Post> posts, {
  String? pendingLogoPath,
  String? pendingCoverPath,
});

/// State manager for the signed-in owner's workshop dashboard and post list.
class MyWorkshopProvider extends ChangeNotifier implements Resettable {
  MyWorkshopProvider({
    required GetMyWorkshopUseCase getMyWorkshop,
    required GetWorkshopPostsUseCase getWorkshopPosts,
    required CreateWorkshopUseCase createWorkshop,
    required UpdateWorkshopUseCase updateWorkshop,
    required UploadWorkshopImageUseCase uploadWorkshopImage,
    required DeletePostUseCase deletePost,
    SyncPublicWorkshopCallback? onSyncWorkshop,
    Future<void> Function()? onReloadDirectory,
  })  : _getMyWorkshop = getMyWorkshop,
        _getWorkshopPosts = getWorkshopPosts,
        _createWorkshop = createWorkshop,
        _updateWorkshop = updateWorkshop,
        _uploadWorkshopImage = uploadWorkshopImage,
        _deletePost = deletePost,
        _onSyncWorkshop = onSyncWorkshop,
        _onReloadDirectory = onReloadDirectory;

  final GetMyWorkshopUseCase _getMyWorkshop;
  final GetWorkshopPostsUseCase _getWorkshopPosts;
  final CreateWorkshopUseCase _createWorkshop;
  final UpdateWorkshopUseCase _updateWorkshop;
  final UploadWorkshopImageUseCase _uploadWorkshopImage;
  final DeletePostUseCase _deletePost;

  SyncPublicWorkshopCallback? _onSyncWorkshop;
  Future<void> Function()? _onReloadDirectory;

  MyWorkshop? _myWorkshop;
  final List<Post> _posts = [];
  String? _pendingLogoPath;
  String? _pendingCoverPath;
  final List<String> _pendingGalleryPaths = [];
  ViewStatus _status = ViewStatus.initial;
  String? _errorMessage;

  MyWorkshop? get myWorkshop => _myWorkshop;
  int get followersCount => _myWorkshop?.followersCount ?? 0;
  List<Post> get posts => List.unmodifiable(_posts);
  int get postCount => _posts.length;
  String? get pendingLogoPath => _pendingLogoPath;
  String? get pendingCoverPath => _pendingCoverPath;
  List<String> get pendingGalleryPaths =>
      List.unmodifiable(_pendingGalleryPaths);
  ViewStatus get status => _status;
  bool get isLoading => _status == ViewStatus.loading;
  String? get errorMessage => _errorMessage;

  void setSyncCallbacks({
    SyncPublicWorkshopCallback? onSyncWorkshop,
    Future<void> Function()? onReloadDirectory,
  }) {
    _onSyncWorkshop = onSyncWorkshop;
    _onReloadDirectory = onReloadDirectory;
  }

  void _syncPublic() {
    _onSyncWorkshop?.call(
      _myWorkshop,
      _posts,
      pendingLogoPath: _pendingLogoPath,
      pendingCoverPath: _pendingCoverPath,
    );
  }

  Future<void> load({String? userId, String fallbackUsername = ''}) async {
    _status = ViewStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _getMyWorkshop(
      GetMyWorkshopParams(userId: userId, fallbackUsername: fallbackUsername),
    );
    switch (result) {
      case Ok(:final data):
        _myWorkshop = data;
        _status = ViewStatus.success;
        _syncPublic();
      case Err(:final failure):
        _status = ViewStatus.failure;
        _errorMessage = failure.message;
    }
    notifyListeners();
  }

  Future<void> loadPosts(String workshopId) async {
    final result = await _getWorkshopPosts(
      GetWorkshopPostsParams(workshopId: workshopId),
    );
    switch (result) {
      case Ok(:final data):
        _posts
          ..clear()
          ..addAll(data);
        _errorMessage = null;
        _syncPublic();
        notifyListeners();
      case Err(:final failure):
        _errorMessage = failure.message;
        notifyListeners();
    }
  }

  Future<MyWorkshop?> create(CreateWorkshopParams params) async {
    _status = ViewStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _createWorkshop(params);
    switch (result) {
      case Ok(:final data):
        _myWorkshop = data;
        _status = ViewStatus.success;
        _syncPublic();
        notifyListeners();
        await _onReloadDirectory?.call();
        return data;
      case Err(:final failure):
        _status = ViewStatus.failure;
        _errorMessage = failure.message;
        notifyListeners();
        return null;
    }
  }

  Future<bool> updateInfo({
    String? name,
    String? username,
    String? city,
    String? description,
    int? yearsOfExperience,
  }) async {
    final previous = _myWorkshop;
    if (previous == null) return false;

    final trimmedName = name?.trim();
    final trimmedUsername = username?.replaceFirst('@', '').trim();
    final trimmedCity = city?.trim();

    final updated = previous.copyWith(
      name: (trimmedName != null && trimmedName.isNotEmpty)
          ? trimmedName
          : previous.name,
      username: (trimmedUsername != null && trimmedUsername.isNotEmpty)
          ? trimmedUsername
          : previous.username,
      city: (trimmedCity != null && trimmedCity.isNotEmpty)
          ? trimmedCity
          : previous.city,
      description: description ?? previous.description,
      yearsOfExperience: yearsOfExperience ?? previous.yearsOfExperience,
    );

    _myWorkshop = updated;
    _errorMessage = null;
    _syncPublic();
    notifyListeners();

    final result = await _updateWorkshop(
      UpdateWorkshopParams(
        workshopId: previous.id,
        name: updated.name,
        handle: updated.username,
        city: updated.city,
        description: description,
        yearsOfExperience: yearsOfExperience,
      ),
    );
    switch (result) {
      case Ok():
        return true;
      case Err(:final failure):
        _myWorkshop = previous;
        _errorMessage = failure.message;
        _syncPublic();
        notifyListeners();
        return false;
    }
  }

  Future<bool> uploadAndSetCover(String localFilePath) {
    return _uploadAndSetSingleImage(
      kind: WorkshopImageKind.cover,
      localFilePath: localFilePath,
      setPending: (path) => _pendingCoverPath = path,
      applyUrl: (workshop, url) => workshop.copyWith(coverUrl: url),
      buildUpdate: (id, url) => UpdateWorkshopParams(workshopId: id, coverUrl: url),
    );
  }

  Future<bool> uploadAndSetLogo(String localFilePath) {
    return _uploadAndSetSingleImage(
      kind: WorkshopImageKind.logo,
      localFilePath: localFilePath,
      setPending: (path) => _pendingLogoPath = path,
      applyUrl: (workshop, url) => workshop.copyWith(logoUrl: url),
      buildUpdate: (id, url) => UpdateWorkshopParams(workshopId: id, logoUrl: url),
    );
  }

  Future<bool> _uploadAndSetSingleImage({
    required WorkshopImageKind kind,
    required String localFilePath,
    required void Function(String? path) setPending,
    required MyWorkshop Function(MyWorkshop workshop, String url) applyUrl,
    required UpdateWorkshopParams Function(String workshopId, String url)
        buildUpdate,
  }) async {
    final current = _myWorkshop;
    if (current == null) return false;

    setPending(localFilePath);
    _errorMessage = null;
    _syncPublic();
    notifyListeners();

    final uploadResult = await _uploadWorkshopImage(
      UploadWorkshopImageParams(
        ownerId: current.ownerId,
        kind: kind,
        localFilePath: localFilePath,
      ),
    );

    switch (uploadResult) {
      case Err(:final failure):
        setPending(null);
        _errorMessage = failure.message;
        _syncPublic();
        notifyListeners();
        return false;
      case Ok(:final data):
        final updateResult = await _updateWorkshop(buildUpdate(current.id, data));
        switch (updateResult) {
          case Ok():
            _myWorkshop = applyUrl(_myWorkshop ?? current, data);
            setPending(null);
            _syncPublic();
            notifyListeners();
            return true;
          case Err(:final failure):
            setPending(null);
            _errorMessage = failure.message;
            _syncPublic();
            notifyListeners();
            return false;
        }
    }
  }

  Future<bool> uploadAndAddGalleryImage(String localFilePath) async {
    final current = _myWorkshop;
    if (current == null) return false;

    _pendingGalleryPaths.add(localFilePath);
    _errorMessage = null;
    notifyListeners();

    final uploadResult = await _uploadWorkshopImage(
      UploadWorkshopImageParams(
        ownerId: current.ownerId,
        kind: WorkshopImageKind.gallery,
        localFilePath: localFilePath,
      ),
    );

    switch (uploadResult) {
      case Err(:final failure):
        _pendingGalleryPaths.remove(localFilePath);
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      case Ok(:final data):
        final latest = _myWorkshop ?? current;
        final updatedGallery = List<String>.from(latest.galleryUrls)..add(data);
        final updateResult = await _updateWorkshop(
          UpdateWorkshopParams(
            workshopId: latest.id,
            galleryUrls: updatedGallery,
          ),
        );
        _pendingGalleryPaths.remove(localFilePath);
        switch (updateResult) {
          case Ok():
            _myWorkshop = latest.copyWith(galleryUrls: updatedGallery);
            _syncPublic();
            notifyListeners();
            return true;
          case Err(:final failure):
            _errorMessage = failure.message;
            notifyListeners();
            return false;
        }
    }
  }

  Future<bool> removeGalleryImageAt(int index) async {
    final previous = _myWorkshop;
    if (previous == null) return false;

    final remoteCount = previous.galleryUrls.length;
    if (index < 0 || index >= remoteCount + _pendingGalleryPaths.length) {
      return false;
    }

    if (index >= remoteCount) {
      _pendingGalleryPaths.removeAt(index - remoteCount);
      notifyListeners();
      return true;
    }

    final updatedGallery = List<String>.from(previous.galleryUrls)
      ..removeAt(index);
    _myWorkshop = previous.copyWith(galleryUrls: updatedGallery);
    _errorMessage = null;
    _syncPublic();
    notifyListeners();

    final result = await _updateWorkshop(
      UpdateWorkshopParams(
        workshopId: previous.id,
        galleryUrls: updatedGallery,
      ),
    );
    switch (result) {
      case Ok():
        return true;
      case Err(:final failure):
        _myWorkshop = previous;
        _errorMessage = failure.message;
        _syncPublic();
        notifyListeners();
        return false;
    }
  }

  /// Inserts [newPost] at the top of the owner's list.
  void addPost(Post newPost) {
    _posts.insert(0, newPost);
    _syncPublic();
    notifyListeners();
  }

  /// Replaces the post with the same [id] with [updatedPost].
  void updatePost(Post updatedPost) {
    final index = _posts.indexWhere((p) => p.id == updatedPost.id);
    if (index != -1) {
      _posts[index] = updatedPost;
    }
    _syncPublic();
    notifyListeners();
  }

  /// Deletes the post with [postId] remotely, then removes it locally on [Ok].
  Future<bool> deletePost(String postId) async {
    _errorMessage = null;
    final result = await _deletePost(postId);
    switch (result) {
      case Ok():
        _posts.removeWhere((p) => p.id == postId);
        _syncPublic();
        notifyListeners();
        return true;
      case Err(:final failure):
        _errorMessage = failure.message;
        notifyListeners();
        return false;
    }
  }

  @override
  void reset() {
    _myWorkshop = null;
    _posts.clear();
    _pendingLogoPath = null;
    _pendingCoverPath = null;
    _pendingGalleryPaths.clear();
    _status = ViewStatus.initial;
    _errorMessage = null;
    _onSyncWorkshop?.call(null, const []);
    notifyListeners();
  }
}
