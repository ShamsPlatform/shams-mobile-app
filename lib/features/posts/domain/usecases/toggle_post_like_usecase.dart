import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/repositories/post_repository.dart';

/// Toggles like state for [postId] and returns the updated `isLiked` flag.
class TogglePostLikeUseCase implements UseCase<bool, String> {
  TogglePostLikeUseCase(this._postRepository);

  final PostRepository _postRepository;

  @override
  Future<Result<bool>> call(String postId) {
    return _postRepository.toggleLike(postId);
  }
}
