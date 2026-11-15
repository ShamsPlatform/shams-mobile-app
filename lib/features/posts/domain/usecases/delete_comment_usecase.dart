import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/repositories/post_repository.dart';

/// Deletes a comment by ID.
class DeleteCommentUseCase implements UseCase<void, String> {
  DeleteCommentUseCase(this._postRepository);

  final PostRepository _postRepository;

  @override
  Future<Result<void>> call(String commentId) {
    return _postRepository.deleteComment(commentId);
  }
}
