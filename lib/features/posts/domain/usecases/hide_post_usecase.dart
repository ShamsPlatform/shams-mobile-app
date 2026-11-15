import 'package:shams_mobile_app/core/result/result.dart';
import 'package:shams_mobile_app/core/usecase/usecase.dart';
import 'package:shams_mobile_app/features/posts/domain/repositories/post_repository.dart';

/// Hides a post from the current user's feed.
class HidePostUseCase implements UseCase<void, String> {
  HidePostUseCase(this._postRepository);

  final PostRepository _postRepository;

  @override
  Future<Result<void>> call(String postId) {
    return _postRepository.hidePost(postId);
  }
}
