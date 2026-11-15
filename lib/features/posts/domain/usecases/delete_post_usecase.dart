import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/repositories/post_repository.dart';

/// Permanently deletes a post by ID.
class DeletePostUseCase implements UseCase<void, String> {
  DeletePostUseCase(this._postRepository);

  final PostRepository _postRepository;

  @override
  Future<Result<void>> call(String postId) {
    return _postRepository.deletePost(postId);
  }
}
