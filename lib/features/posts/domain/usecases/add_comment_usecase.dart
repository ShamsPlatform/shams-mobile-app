import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/entities/comment.dart';
import 'package:shams_mobile_app/features/posts/domain/repositories/post_repository.dart';

class AddCommentParams {
  const AddCommentParams({required this.postId, required this.text});

  final String postId;
  final String text;
}

/// Adds a new comment to a post and returns the created [Comment].
class AddCommentUseCase implements UseCase<Comment, AddCommentParams> {
  AddCommentUseCase(this._postRepository);

  final PostRepository _postRepository;

  @override
  Future<Result<Comment>> call(AddCommentParams params) {
    return _postRepository.addComment(
      postId: params.postId,
      text: params.text,
    );
  }
}
