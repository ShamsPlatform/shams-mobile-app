import 'package:flutter/foundation.dart';
import 'package:shams_mobile_app/core/presentation/view_status.dart';
import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/features/posts/domain/entities/post.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/create_post_usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/usecases/update_post_usecase.dart';

/// Screen-scoped state manager for creating and editing a [Post].
class PostEditorProvider extends ChangeNotifier {
  PostEditorProvider({
    required CreatePostUseCase createPost,
    required UpdatePostUseCase updatePost,
  })  : _createPost = createPost,
        _updatePost = updatePost;

  final CreatePostUseCase _createPost;
  final UpdatePostUseCase _updatePost;

  ViewStatus _status = ViewStatus.initial;
  String? _errorMessage;

  ViewStatus get status => _status;
  bool get isLoading => _status == ViewStatus.loading;
  String? get errorMessage => _errorMessage;

  Future<Post?> create({
    required String workshopId,
    required String textDetails,
    List<String> imagePaths = const [],
    bool isHighlighted = false,
  }) async {
    _status = ViewStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _createPost(
      CreatePostParams(
        workshopId: workshopId,
        textDetails: textDetails,
        imagePaths: imagePaths,
        isHighlighted: isHighlighted,
      ),
    );

    switch (result) {
      case Ok(:final data):
        _status = ViewStatus.success;
        notifyListeners();
        return data;
      case Err(:final failure):
        _status = ViewStatus.failure;
        _errorMessage = failure.message;
        notifyListeners();
        return null;
    }
  }

  Future<Post?> update({
    required Post original,
    required String textDetails,
    List<String>? images,
    required bool isHighlighted,
  }) async {
    _status = ViewStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _updatePost(
      UpdatePostParams(
        postId: original.id,
        textDetails: textDetails,
        isHighlighted: isHighlighted,
      ),
    );

    switch (result) {
      case Ok():
        _status = ViewStatus.success;
        notifyListeners();
        return original.copyWith(
          textDetails: textDetails,
          isHighlighted: isHighlighted,
          images: images ?? original.images,
        );
      case Err(:final failure):
        _status = ViewStatus.failure;
        _errorMessage = failure.message;
        notifyListeners();
        return null;
    }
  }
}
