import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/repositories/post_repository.dart';

/// Toggles like state for [commentId] and returns the updated `isLiked` flag.
class ToggleCommentLikeUseCase implements UseCase<bool, String> {
  ToggleCommentLikeUseCase(this._postRepository);

  final PostRepository _postRepository;

  @override
  Future<Result<bool>> call(String commentId) {
    return _postRepository.toggleCommentLike(commentId);
  }
}
